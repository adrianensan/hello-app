import SwiftUI

struct NavigationPageBackswipe: ViewModifier {
  
  @Environment(PagerModel.self) private var pagerModel
  @Environment(BackProgressModel.self) private var backProgressModel
  
  @GestureState private var backDragGestureState: CGSize = .zero
  let size: CGSize
  
  var pageSpacing: CGFloat { size.width + 8 }
  
  func body(content: Content) -> some View {
    content
      .compositingGroup()
      .offset(x: -CGFloat(pagerModel.viewDepth - 1) * pageSpacing + backDragGestureState.width)
      .animation(.pageAnimation, value: pagerModel.viewDepth)
      .animation(backDragGestureState == .zero ? .pageAnimation : .interactive, value: backDragGestureState)
      .nest {
#if os(tvOS)
        $0
#else
        $0.highPriorityGesture(DragGesture(minimumDistance: pagerModel.config.allowsBack && pagerModel.viewDepth > 1 && pagerModel.activePage?.options.allowBackOverride != false ? 8 : .infinity, coordinateSpace: .global)
          .updating($backDragGestureState) { drag, state, transaction in
            if drag.translation.width < 0 {
              state = CGSize(width: 0, height: 0)
            } else {
              state = CGSize(width: drag.translation.width, height: 0)
            }
          }.onEnded { drag in
            if drag.predictedEndTranslation.width > 200 {
              pagerModel.popView()
              ButtonHaptics.buttonFeedback()
            }
          })
#endif
      }.onChange(of: backDragGestureState) {
        let progress = min(1, max(0, $0.width / 200))
        if backProgressModel.backProgress != progress {
          backProgressModel.backProgress = progress
        }
      }
  }
}

extension View {
  func handlePageBackSwipe(pageSize: CGSize) -> some View {
    self.modifier(NavigationPageBackswipe(size: pageSize))
  }
}
