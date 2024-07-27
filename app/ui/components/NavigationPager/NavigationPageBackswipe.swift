import SwiftUI

@MainActor
struct NavigationPageBackswipe: ViewModifier {
  
  @Environment(PagerModel.self) private var pagerModel
  @Environment(BackProgressModel.self) private var backProgressModel
  @Environment(\.helloPagerConfig) private var pagerConfig
  
  @GestureState private var backDragGestureState: CGSize = .zero
//  @State private var touchesModel: TouchesModel = .main
  let size: CGSize
  
  var pageSpacing: CGFloat { size.width + 10 }
  
  func body(content: Content) -> some View {
    content
      .compositingGroup()
      .offset(x: -CGFloat(pagerModel.viewDepth - 1) * pageSpacing + backDragGestureState.width)
      .animation(.pageAnimation, value: pagerModel.viewDepth)
      .animation(backDragGestureState == .zero ? .pageAnimation : .interactive, value: backDragGestureState)
      .nest {
#if os(iOS)
        $0.gesture(type: pagerConfig.backGestureType, DragGesture(minimumDistance: pagerModel.config.allowsBack && pagerModel.viewDepth > 1 && pagerModel.activePage?.options.allowBackOverride != false ? 10 : .infinity, coordinateSpace: .global)
          .updating($backDragGestureState) { drag, state, transaction in
            if backProgressModel.backSwipeAllowance == nil {
              backProgressModel.backSwipeAllowance = 0.5 * drag.translation.width > abs(drag.translation.height)
            }
            
            if backProgressModel.backSwipeAllowance == true {
              if drag.translation.width > 0 {
                state = CGSize(width: drag.translation.width, height: 0)
              } else {
                state = CGSize(width: -sqrt(abs(drag.translation.width)), height: 0)
              }
            }
//            if TouchesModel.main.hasScrolledDuringTouch || drag.translation.width <= 0 {
//              state = CGSize(width: 0, height: 0)
//              if backProgressModel.backSwipeAllowance == nil {
//                backProgressModel.backSwipeAllowance = false
//              }
//            } else if backProgressModel.backSwipeAllowance != false {
//              state = CGSize(width: drag.translation.width, height: 0)
//              backProgressModel.backSwipeAllowance = true
//            }
          }.onEnded { drag in
            if backProgressModel.backSwipeAllowance == true && drag.predictedEndTranslation.width > 200 {
              pagerModel.popView()
              ButtonHaptics.buttonFeedback()
            }
            backProgressModel.backSwipeAllowance = nil
            Task {
              backProgressModel.backProgress = 0
            }
          })
#else
        $0
#endif
      }.onChange(of: backDragGestureState) {
        let progress = min(1, max(0, $0.width / 200))
        if backProgressModel.backProgress != progress {
          backProgressModel.backProgress = progress
        }
      }
//      .onChange(of: touchesModel.activeTouches.isEmpty) {
//        if touchesModel.activeTouches.isEmpty {
//          Task {
//            try await Task.sleep(seconds: 0.2)
//            if touchesModel.activeTouches.isEmpty && backProgressModel.backSwipeAllowance != nil {
//              backProgressModel.backProgress = 0
//              backProgressModel.backSwipeAllowance = nil
//            }
//          }
//        }
//      }
  }
}

extension View {
  func handlePageBackSwipe(pageSize: CGSize) -> some View {
    self.modifier(NavigationPageBackswipe(size: pageSize))
  }
}
