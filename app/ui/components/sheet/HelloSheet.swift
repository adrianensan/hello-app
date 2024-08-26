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
  var sheetSize: CGSize = .zero
  
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
    ButtonHaptics.buttonFeedback()
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
  
  private var content: @MainActor () -> Content
  
  public init(dragToDismissType: GestureType = .highPriority, content: @escaping @MainActor () -> Content) {
    let sheetModel = HelloSheetModel(dragToDismissType: dragToDismissType)
    self._model = State(initialValue: sheetModel)
    self.content = content
  }  

  public var body: some View {
    content()
      .coordinateSpace(.sheet)
      .overlay(HelloCloseButton { model.dismiss() }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing))
      .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
      .padding(.bottom, 60)
      .background(theme.backgroundView(for: RoundedRectangle(cornerRadius: 30, style: .continuous), isBaseLayer: false)
        .onTapGesture { globalDismissKeyboard() })
      .padding(.bottom, -60)
      .padding(.top, safeArea.top + 16)
      .handleSheetDismissDrag()
      .transformEnvironment(\.safeArea) { $0.top = 0 }
      .environment(model)
      .environment(\.helloDismiss, { model.dismiss() })
  }
}
#endif
