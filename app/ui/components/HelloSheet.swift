#if os(iOS)
import SwiftUI

public struct HelloSheetCoordinateSpace: CoordinateSpaceProtocol {
  public var coordinateSpace: CoordinateSpace { .named("hello-sheet") }
}

public extension CoordinateSpaceProtocol where Self == HelloSheetCoordinateSpace {
  public static var sheet: HelloSheetCoordinateSpace { HelloSheetCoordinateSpace() }
}

public extension NamedCoordinateSpace {
  public static var sheet: NamedCoordinateSpace { .named("hello-sheet") }
}

@MainActor
@Observable
public class HelloSheetModel {
  public private(set) var dragToDismissType: GestureType
  
  public init(dragToDismissType: GestureType = .highPriority) {
    self.dragToDismissType = dragToDismissType
  }
  
  public func update(dragToDismissType: GestureType) {
    guard self.dragToDismissType != dragToDismissType else { return }
    self.dragToDismissType = dragToDismissType
  }
}

public struct HelloSheet<Content: View>: View {
  
  @Environment(\.windowFrame) private var windowFrame
  @Environment(\.safeArea) private var safeArea
  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel
  
  @State private var isVisible: Bool
  @State private var model: HelloSheetModel
  @GestureState private var drag: CGSize = .zero
  
  private var id: String
  private var content: () -> Content
  
  public init(id: String, dragToDismissType: GestureType = .highPriority, content: @MainActor @escaping () -> Content) {
    self.id = id
    self._isVisible = State(initialValue: false)
    self._model = State(initialValue: HelloSheetModel(dragToDismissType: dragToDismissType))
    self.content = content
  }
  
  private var yDrag: CGFloat {
    if drag.height < 0 {
      0.06 * drag.height
    } else {
      drag.height
    }
  }
  
  func dismiss() {
    isVisible = false
    Task {
      windowModel.dismiss(id: id)
    }
  }

  public var body: some View {
    content()
      .padding(.bottom, safeArea.bottom)
      .clipShape(RoundedRectangle(cornerRadius: Device.current.screenCornerRadius, style: .continuous))
      .clipShape(RoundedRectangle(cornerRadius: Device.current.screenCornerRadius, style: .continuous))
      .background(theme.backgroundView(for: RoundedRectangle(cornerRadius: Device.current.screenCornerRadius, style: .continuous), isBaseLayer: false))
      .environment(model)
      .coordinateSpace(.sheet)
      .compositingGroup()
      .frame(height: isVisible ? nil : 1, alignment: .top)
      .animation(.dampSpring, value: isVisible)
      .offset(y: isVisible ? yDrag : 0)
      .animation(yDrag == 0 ? .dampSpring : .interactive, value: yDrag)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
      .background(Color.black
        .opacity(isVisible ? 0.2 : 0)
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .sheet)
          .updating($drag) { value, state, transaction in
            state = value.translation
          }.onEnded { gesture in
            if gesture.predictedEndTranslation.maxSide == 0 || gesture.predictedEndTranslation.height > 200 {
              dismiss()
            }
          })
        .animation(.easeInOut(duration: 0.2), value: isVisible))
      .gesture(type: model.dragToDismissType, DragGesture(minimumDistance: 1, coordinateSpace: .sheet)
        .updating($drag) { value, state, transaction in
          state = value.translation
        }.onEnded { gesture in
          if gesture.predictedEndTranslation.maxSide == 0 || gesture.predictedEndTranslation.height > 200 {
            dismiss()
          }
        })
      .allowsHitTesting(isVisible)
      .onAppear {
        guard !isVisible else { return }
        isVisible = true
      }.transformEnvironment(\.safeArea) { $0.top = 0 }
      .environment(\.helloDismiss, { dismiss() })
      .environment(\.hasAppeared, isVisible)
  }
}
#endif
