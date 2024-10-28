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
  public var isFloating: Bool = false
  var sheetSize: CGSize = .zero
  public var waitingForSizing: Bool = false
  
  public var dismissProgress: CGFloat { max(0, min(1, dismissDrag / 200)) }
  
  public private(set) var dragToDismissType: GestureType
  @ObservationIgnored var dragCanDismiss: Bool?
  
  @ObservationIgnored var isDraggingNavBar: Bool = false
  var shouldScrollInsteadOfDismiss: Bool { !(pagerModel?.activePageIsReadyForDismiss ?? true) }
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
    ButtonHaptics.buttonFeedback()
  }
}

public struct HelloSheet<Content: View>: View {
  
  @Environment(\.windowFrame) private var windowFrame
  @Environment(\.safeArea) private var safeArea
  @Environment(\.pixelsPerPoint) private var pixelsPerPoint
  @Environment(\.theme) private var theme
  @Environment(\.colorScheme) private var colorScheme
  @Environment(HelloWindowModel.self) private var windowModel
  
  @State private var model: HelloSheetModel
  
  private var debugModel: DebugModel = .main
  
  private var content: @MainActor () -> Content
  
  public init(dragToDismissType: GestureType = .highPriority, content: @escaping @MainActor () -> Content) {
    let sheetModel = HelloSheetModel(dragToDismissType: dragToDismissType)
    self._model = State(initialValue: sheetModel)
    self.content = content
  }

  private var isfloating: Bool {
    windowFrame.size.minSide > 700
  }
  
  var fillShape: AnyInsettableShape {
    .rect(cornerRadii: RectangleCornerRadii(
      topLeading: 30,
      bottomLeading: isfloating ? 30 : 0,
      bottomTrailing: isfloating ? 30 : 0,
      topTrailing: 30))
  }
  
  var shape: AnyInsettableShape {
    .rect(cornerRadii: RectangleCornerRadii(
      topLeading: 30,
      bottomLeading: isfloating ? 30 : !windowModel.isFullscreenWidth ? 0 : Device.current.screenCornerRadiusPixels / pixelsPerPoint,
      bottomTrailing: isfloating ? 30 : !windowModel.isFullscreenWidth ? 0 : Device.current.screenCornerRadiusPixels / pixelsPerPoint,
      topTrailing: 30))
  }
  
  var pageShape: AnyInsettableShape {
    .rect(cornerRadii: RectangleCornerRadii(
      topLeading: 30,
      bottomLeading: isfloating ? 30 : !windowModel.isFullscreenWidth ? 0 : Device.current.screenCornerRadiusPixels / pixelsPerPoint,
      bottomTrailing: 0,
      topTrailing: 0))
  }
  
  public var body: some View {
    content()
      .coordinateSpace(.sheet)
      .overlay {
        if model.pagerModel == nil {
          HelloCloseButton { model.dismiss() }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
      }.clipShape(shape)
      .padding(.bottom, isfloating ? 0 : 36)
      .background(theme.backgroundView(for: fillShape, isBaseLayer: true)
        .onTapGesture { globalDismissKeyboard() })
      .padding(.bottom, isfloating ? 0 : -36)
      .overlay(shape.strokeBorder(theme.backgroundOutline, lineWidth: theme.backgroundOutlineWidth))
      .padding(.top, isfloating ? 0 : safeArea.top + 16)
      .handleSheetDismissDrag()
      .transformEnvironment(\.safeArea) {
        $0.top = 0
        if isfloating {
          $0.bottom = 0
        }
      }
      .environment(model)
      .environment(\.viewShape, shape)
      .environment(\.pageShape, pageShape)
      .environment(\.helloDismiss, { model.dismiss() })
      .onChange(of: isfloating, initial: true) {
        model.isFloating = isfloating
      }
  }
}
#endif
