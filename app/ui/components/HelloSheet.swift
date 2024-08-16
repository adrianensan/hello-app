#if os(iOS)
import SwiftUI

import HelloCore

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
  var pagerModel: PagerModel?
  var dismissDrag: CGFloat = 0
  var isVisible: Bool = false
  
  public var dismissProgress: CGFloat { max(0, min(1, dismissDrag / 200)) }
  
  public private(set) var dragToDismissType: GestureType
  @ObservationIgnored var dragCanDismiss: Bool?
  
  var shouldScrollInsteadOfDismiss: Bool { (pagerModel?.activePageScrollOffset ?? 0) < -1 }
  var backProgress: CGFloat { pagerModel?.backProgressModel.backProgress ?? 0 }
  
  public init(dragToDismissType: GestureType = .highPriority) {
    self.dragToDismissType = dragToDismissType
  }
  
  public func update(dragToDismissType: GestureType) {
    guard self.dragToDismissType != dragToDismissType else { return }
    self.dragToDismissType = dragToDismissType
  }
  
  public func dismiss() {
    guard isVisible else { return }
    isVisible = false
  }
}

public struct HelloSheet<Content: View>: View {
  
  @Environment(\.windowFrame) private var windowFrame
  @Environment(\.safeArea) private var safeArea
  @Environment(\.theme) private var theme
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.viewID) private var viewID
  @Environment(HelloWindowModel.self) private var windowModel
  
  @State private var model: HelloSheetModel
  @GestureState private var drag: CGFloat?
  
  private var content: () -> Content
  
  public init(dragToDismissType: GestureType = .highPriority, content: @MainActor @escaping () -> Content) {
    let sheetModel = HelloSheetModel(dragToDismissType: dragToDismissType)
    self._model = State(initialValue: sheetModel)
    self._drag = GestureState(initialValue: 0, reset: { _, _ in
      if sheetModel.dismissDrag != 0 {
        sheetModel.dismissDrag = 0
      }
    })
    self.content = content
  }
  
  private var yDrag: CGFloat {
    if model.dismissDrag < 0 {
      0.06 * model.dismissDrag
    } else {
      model.dismissDrag
    }
  }

  public var body: some View {
    content()
      .disabled(yDrag != 0)
      .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
      .padding(.bottom, 60)
      .background(theme.backgroundView(for: RoundedRectangle(cornerRadius: 30, style: .continuous), isBaseLayer: false)
        .onTapGesture { globalDismissKeyboard() })
      .padding(.bottom, -60)
      .coordinateSpace(.sheet)
      .overlay {
        HelloCloseButton { model.dismiss() }
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
      }
      .compositingGroup()
      .frame(height: model.isVisible ? nil : 1, alignment: .top)
      .padding(.top, safeArea.top + 8)
      .animation(.dampSpring, value: model.isVisible)
      .offset(y: model.isVisible ? yDrag : 0)
      .animation(yDrag == 0 ? .dampSpring : .interactive, value: yDrag)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
      .background(HelloBackgroundDimmingView()
        .opacity(model.isVisible ? 1 : 0)
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .sheet)
          .updating($drag) { value, state, transaction in
            model.dismissDrag = value.translation.height
          }.onEnded { gesture in
            if gesture.predictedEndTranslation.maxSide == 0 || gesture.predictedEndTranslation.height > 200 {
              model.dismiss()
            } else {
              model.dismissDrag = 0
            }
          })
        .animation(.easeInOut(duration: 0.2), value: model.isVisible))
      .gesture(type: model.dragToDismissType, DragGesture(minimumDistance: 8, coordinateSpace: .sheet)
        .updating($drag) { drag, state, transaction in
          if model.dragCanDismiss == nil {
            model.dragCanDismiss = !model.shouldScrollInsteadOfDismiss && 0.8 * drag.translation.height > abs(drag.translation.width)
          }
          
          if model.dragCanDismiss == true {
            model.dismissDrag = drag.translation.height
          }
        }.onEnded { gesture in
          if model.dragCanDismiss == true &&
              (gesture.predictedEndTranslation.maxSide == 0 || gesture.predictedEndTranslation.height > 200) {
            model.dismiss()
          } else {
            if model.dismissDrag != 0 {
              model.dismissDrag = 0
            }
          }
          model.dragCanDismiss = nil
        })
      .allowsHitTesting(model.isVisible)
      .task {
        try? await Task.sleepForOneFrame()
        model.isVisible = true
      }.transformEnvironment(\.safeArea) { $0.top = 0 }
      .environment(model)
      .environment(\.helloDismiss, { model.dismiss() })
      .environment(\.hasAppeared, model.isVisible)
      .onChange(of: model.isVisible) {
        if !model.isVisible {
          Task {
            windowModel.dismiss(id: viewID)
          }
        }
      }
  }
}
#endif
