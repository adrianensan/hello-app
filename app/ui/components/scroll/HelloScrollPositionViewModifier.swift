import SwiftUI

struct HelloScrollPositionViewModifier: ViewModifier {
  
  @Environment(HelloScrollModel.self) private var scrollModel
  
  func body(content: Content) -> some View {
    @Bindable var scrollModel = scrollModel
    content.scrollPosition($scrollModel.swiftuiScrollPosition)
  }
}

struct HelloScrollTouchViewModifier: ViewModifier {
  
  @Environment(HelloScrollModel.self) private var scrollModel
  #if os(iOS)
  @OptionalEnvironment(HelloSheetModel.self) private var sheetModel
  @OptionalEnvironment(HelloPagerModel.self) private var pagerModel
  #endif
  
  @GestureState private var isTouching: Bool = false
  
  private func reset() {
    scrollModel.setIsTouching(false)
    #if os(iOS)
    if sheetModel?.scrollPreventingDismiss == scrollModel.id {
      sheetModel?.scrollPreventingDismiss = nil
    }
    if scrollModel.axes.isHorizontal {
      pagerModel?.backGestureOverride = nil
    }
    #endif
  }
  
  func body(content: Content) -> some View {
    content
      .simultaneousGesture(
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
          .updating($isTouching) { gesture, isTouching, _ in
            if !isTouching {
              isTouching = true
              scrollModel.setIsTouching(true)
              #if os(iOS)
              if !scrollModel.readyForDismiss {
                sheetModel?.scrollPreventingDismiss = scrollModel.id
              }
              if !scrollModel.isScrolledToLeading && scrollModel.axes.isHorizontal {
                pagerModel?.backGestureOverride = scrollModel.id
              }
              #endif
            }
          }.onEnded { _ in reset() })
      .when(!isTouching) { reset() }
  }
}
