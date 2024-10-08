import SwiftUI

struct NavigationPageBackswipe: ViewModifier {
  
  @Environment(\.theme) private var theme
  @Environment(\.pageShape) private var pageShape
  @Environment(\.helloPagerConfig) private var pagerConfig
  @Environment(PagerModel.self) private var pagerModel
  @Environment(BackProgressModel.self) private var backProgressModel
  
  @GestureState private var backDragWidth: CGFloat?
//  @State private var touchesModel: TouchesModel = .main
  let pageID: String
  let size: CGSize
  
  var isActive: Bool {
    pagerModel.viewStack.firstIndex { $0.id == pageID } ?? .max >= pagerModel.viewDepth - 1
  }
  
  var offset: CGFloat {
    let pageIndex = pagerModel.viewStack.firstIndex { $0.id == pageID } ?? .max
    if pageIndex > pagerModel.viewDepth - 1 {
      return size.width + 10
    } else if pageIndex == pagerModel.viewDepth - 1 {
      return backProgressModel.drag ?? 0
    } else if pageIndex == pagerModel.viewDepth - 2 {
      return 0.5 * (-size.width + (backProgressModel.drag ?? 0))
    } else {
      return -1 * size.width - 10
    }
  }
  
  var backProgress: CGFloat {
    min(1, max(0, (-size.width + (backProgressModel.drag ?? 0)) / (-size.width)))
  }
  
  func body(content: Content) -> some View {
    content
      .clipShape(pageShape)
      .background(theme.backgroundView(for: pageShape, isBaseLayer: true)
        .shadow(color: .black.opacity(pagerModel.activePageID == pageID.id ? 0.2 : 0), radius: 16)
        .onTapGesture { globalDismissKeyboard() })
      .overlay(
        HelloBackgroundDimmingView()
          .opacity(isActive ? 0 : 0.8 * backProgress)
          .animation(.pageAnimation, value: isActive)
//          .animation(.interactive, value: backProgress)
          .allowsTightening(false)
      ).overlay(pageShape.strokeBorder(theme.backgroundOutline, lineWidth: theme.backgroundOutlineWidth)
        .opacity(backProgressModel.drag == nil ? 0 : 1))
      .allowsHitTesting(pagerModel.activePageID == pageID && pagerModel.allowInteraction && backProgressModel.backProgress == 0)
      .disabled(pagerModel.activePageID != pageID || backProgressModel.backProgress != 0)
      .compositingGroup()
      .offset(x: offset)
//      .animation(.pageAnimation, value: pagerModel.viewDepth)
      .animation(backProgressModel.drag == nil ? .pageAnimation : nil, value: offset)
      .nest {
#if os(iOS)
        $0.gesture(type: pagerConfig.backGestureType, DragGesture(minimumDistance: pagerModel.config.allowsBack && pagerModel.viewDepth > 1 && pagerModel.activePage?.options.allowBackOverride != false ? 10 : .infinity, coordinateSpace: .global)
          .updating($backDragWidth) { drag, state, transaction in
            if backProgressModel.backSwipeAllowance == nil {
              backProgressModel.backSwipeAllowance = 0.5 * drag.translation.width > abs(drag.translation.height)
            }
            
            var dragWidth: CGFloat? = nil
            if backProgressModel.backSwipeAllowance == true {
              if drag.translation.width > 0 {
                dragWidth = drag.translation.width
              } else {
                dragWidth = -sqrt(abs(drag.translation.width))
              }
            }
            
            state = dragWidth
            backProgressModel.drag = dragWidth
            
            let progress = min(1, max(0, (dragWidth ?? 0) / 200))
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
            backProgressModel.reset()
          })
#else
        $0
#endif
      }.onChange(of: backDragWidth) {
        if backDragWidth == nil {
          Task {
            try await Task.sleepForOneFrame()
            backProgressModel.reset()
          }
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
  func handlePageBackSwipe(pageID: String, pageSize: CGSize) -> some View {
    self.modifier(NavigationPageBackswipe(pageID: pageID, size: pageSize))
  }
}
