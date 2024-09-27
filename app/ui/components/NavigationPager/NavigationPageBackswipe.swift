import SwiftUI

struct NavigationPageBackswipe: ViewModifier {
  
  @Environment(PagerModel.self) private var pagerModel
  @Environment(BackProgressModel.self) private var backProgressModel
  @Environment(\.helloPagerConfig) private var pagerConfig
  
  @GestureState private var backDragWidth: CGFloat?
//  @State private var touchesModel: TouchesModel = .main
  let size: CGSize
  
  var pageSpacing: CGFloat { size.width + 10 }
  
  func body(content: Content) -> some View {
    content
      .allowsHitTesting(pagerModel.allowInteraction && backProgressModel.backProgress == 0)
      .disabled(backProgressModel.backProgress != 0)
      .compositingGroup()
      .offset(x: -CGFloat(pagerModel.viewDepth - 1) * pageSpacing + (backDragWidth ?? 0))
//      .animation(.pageAnimation, value: pagerModel.viewDepth)
      .animation(backDragWidth == nil ? .pageAnimation : .interactive, value: backDragWidth)
      .nest {
#if os(iOS)
        $0.gesture(type: pagerConfig.backGestureType, DragGesture(minimumDistance: pagerModel.config.allowsBack && pagerModel.viewDepth > 1 && pagerModel.activePage?.options.allowBackOverride != false ? 10 : .infinity, coordinateSpace: .global)
          .updating($backDragWidth) { drag, state, transaction in
            if backProgressModel.backSwipeAllowance == nil {
              backProgressModel.backSwipeAllowance = 0.5 * drag.translation.width > abs(drag.translation.height)
            }
            
            var dragWidth: CGFloat = 0
            if backProgressModel.backSwipeAllowance == true {
              if drag.translation.width > 0 {
                dragWidth = drag.translation.width
              } else {
                dragWidth = -sqrt(abs(drag.translation.width))
              }
            }
            
            state = dragWidth
            
            let progress = min(1, max(0, dragWidth / 200))
            if backProgressModel.backProgress != progress {
              backProgressModel.backProgress = progress
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
            }
            backProgressModel.backSwipeAllowance = nil
            Task {
              if backProgressModel.backProgress != 0 {
                backProgressModel.backProgress = 0
              }
            }
          })
#else
        $0
#endif
      }.onChange(of: backDragWidth) {
        if backDragWidth == nil {
          backProgressModel.backProgress = 0
        }
//        let progress = min(1, max(0, backDragGestureState.width / 200))
//        if backProgressModel.backProgress != progress {
//          backProgressModel.backProgress = progress
//        }
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
