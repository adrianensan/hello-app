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
  
  @GestureState private var isTouching: Bool?
  
  func body(content: Content) -> some View {
    content
      .simultaneousGesture(
        DragGesture(minimumDistance: 8, coordinateSpace: .global)
          .updating($isTouching) { gesture, state, _ in
            if state == nil {
              state = true
              scrollModel.setIsTouching(true)
            }
          })
      .onChange(of: isTouching) {
        if isTouching == nil {
          scrollModel.setIsTouching(false)
        }
      }
  }
}
