#if os(iOS)
import SwiftUI

import HelloCore

public struct HelloSheetCoordinateSpace: CoordinateSpaceProtocol {
  public var coordinateSpace: CoordinateSpace { .named("hello-sheet") }
}

public extension CoordinateSpaceProtocol where Self == HelloSheetCoordinateSpace {
  static var sheet: HelloSheetCoordinateSpace { HelloSheetCoordinateSpace() }
}

public extension NamedCoordinateSpace {
  static var sheet: NamedCoordinateSpace { .named("hello-sheet") }
}

public struct HelloSheetConfig {
  var id: String
  var view: @MainActor () -> AnyView
  
  public init<Content: View>(id: String = String(describing: Content.self), view: @MainActor @escaping () -> Content) {
    self.id = id
    self.view = { AnyView(view()) }
  }
}

@MainActor
@Observable
public class HelloSheetModel {
  
  var pagerModel: HelloPagerModel?
  
  var dismissDrag: CGFloat = 0
  var isVisible: Bool = false
  public var isFloating: Bool = false
  var sheetSize: CGSize = .zero
  public var waitingForSizing: Bool = false
  public var scrollPreventingDismiss: String?
  
  
  @ObservationIgnored var dragCanDismiss: Bool?
  @ObservationIgnored var isDraggingNavBar: Bool = false
  
  public init() {}
  
  var shouldScrollInsteadOfDismiss: Bool { !(pagerModel?.activePageIsReadyForDismiss ?? true) || scrollPreventingDismiss != nil }
  public var dismissProgress: CGFloat { max(0, min(1, dismissDrag / 200)) }
  var backProgress: CGFloat { pagerModel?.backProgressModel.backProgress ?? 0 }
  
  public func dismiss() {
    guard isVisible else { return }
    isVisible = false
    ButtonHaptics.buttonFeedback()
  }
  
  public func reset() {
    isDraggingNavBar = false
    dragCanDismiss = nil
    if dismissDrag != 0 {
      dismissDrag = 0
    }
  }
}

public struct HelloSheet<Content: View>: View {
  
  static var usePaddingOnIOS: Bool { true }
  
  @Environment(\.windowFrame) private var windowFrame
  @Environment(\.safeArea) private var safeArea
  @Environment(\.pixelsPerPoint) private var pixelsPerPoint
  @Environment(\.theme) private var theme
  @Environment(\.colorScheme) private var colorScheme
  @Environment(HelloWindowModel.self) private var windowModel
  
  @State private var model: HelloSheetModel
  
  private var debugModel: DebugModel = .main
  
  private var content: @MainActor () -> Content
  
  public init(content: @escaping @MainActor () -> Content) {
    let sheetModel = HelloSheetModel()
    self._model = State(initialValue: sheetModel)
    self.content = content
  }

  private var isfloating: Bool {
    windowFrame.size.minSide > 700
  }
  
  private var cornerRadius: CGFloat {
    Device.current.screenCornerRadiusPixels / pixelsPerPoint - (Self.usePaddingOnIOS ? 6 : 0)
  }
  
  var fillShape: AnyInsettableShape {
    Self.usePaddingOnIOS ? shape :
    .rect(cornerRadii: RectangleCornerRadii(
      topLeading: 30,
      bottomLeading: isfloating ? 30 : 0,
      bottomTrailing: isfloating ? 30 : 0,
      topTrailing: 30))
  }
  
  var shape: AnyInsettableShape {
    .rect(cornerRadii: RectangleCornerRadii(
      topLeading: 30,
      bottomLeading: isfloating ? 30 : !windowModel.isFullscreenWidth ? 0 : cornerRadius,
      bottomTrailing: isfloating ? 30 : !windowModel.isFullscreenWidth ? 0 : cornerRadius,
      topTrailing: 30))
  }
  
  var pageShape: AnyInsettableShape {
    .rect(cornerRadii: RectangleCornerRadii(
      topLeading: 30,
      bottomLeading: isfloating ? 30 : !windowModel.isFullscreenWidth ? 0 : cornerRadius,
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
      .padding(.bottom, isfloating || Self.usePaddingOnIOS ? 0 : 36)
      .background(theme.backgroundView(for: fillShape, isBaseLayer: true)
        .onTapGesture { globalDismissKeyboard() })
      .padding(.bottom, isfloating || Self.usePaddingOnIOS ? 0 : -36)
      .overlay(shape.strokeBorder(theme.backgroundOutline, lineWidth: theme.backgroundOutlineWidth))
      .handleSheetDismissDrag()
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
