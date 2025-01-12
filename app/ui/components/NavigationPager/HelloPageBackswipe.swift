import SwiftUI

import HelloCore

struct HelloPageBackswipe: ViewModifier {
  
  @Environment(\.theme) private var theme
  @Environment(\.isActive) private var isActive
  @Environment(\.pageShape) private var pageShape
  @Environment(\.viewFrame) private var viewFrame
  @Environment(\.helloPagerConfig) private var pagerConfig
  @Environment(HelloPagerModel.self) private var pagerModel
  @Environment(BackProgressModel.self) private var backProgressModel
  
  @NonObservedState private var lastTimeMoved: TimeInterval = epochTime
  @State private var maskShape: Bool = true
  
  @GestureState private var backDragWidth: CGFloat?
  //  @State private var touchesModel: TouchesModel = .main
  let pageID: String
  let size: CGSize
  
  var isActivePage: Bool {
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
  
  var needsEffects: Bool {
    pagerModel.activePageID == pageID && offset != 0
  }
  
  var effectiveShowEffects: Bool { needsEffects || maskShape }
  
  func body(content: Content) -> some View {
    content
      .padding(.top, effectiveShowEffects ? 0 : 8)
      .clipShape(effectiveShowEffects ? pageShape : .rect)
      .background(theme.backgroundView(for: effectiveShowEffects ? pageShape : .rect, isBaseLayer: true)
        .shadow(color: .black.opacity(effectiveShowEffects && pagerModel.activePageID == pageID.id ? 0.2 : 0), radius: 16)
        .onTapGesture { globalDismissKeyboard() })
      .padding(theme.backgroundOutlineWidth)
      .overlay(pageShape.strokeBorder(theme.backgroundOutline.opacity(effectiveShowEffects ? 1 : 0), lineWidth: theme.backgroundOutlineWidth))
      .padding(-theme.backgroundOutlineWidth)
      .padding(.top, effectiveShowEffects ? 0 : -8)
      .overlay(
        HelloBackgroundDimmingView()
          .opacity(isActivePage ? 0 : 0.8 * backProgress)
          .animation(.pageAnimation, value: isActivePage)
        //          .animation(.interactive, value: backProgress)
          .allowsTightening(false)
      )
      .allowsHitTesting(pagerModel.activePageID == pageID && pagerModel.allowInteraction && backProgressModel.backProgress == 0)
      .disabled(pagerModel.activePageID != pageID || backProgressModel.backProgress != 0)
      .compositingGroup()
      .offset(x: offset)
    //      .animation(.pageAnimation, value: pagerModel.viewDepth)
      .animation(backProgressModel.drag == nil ? .dampSpring : .interactive, value: offset)
      .onChange(of: needsEffects, initial: true) {
        if needsEffects {
          lastTimeMoved = epochTime
          if !maskShape {
            maskShape = true
          }
        } else {
          Task {
            try await Task.sleep(seconds: 0.5)
            guard !needsEffects && epochTime - lastTimeMoved >= 0.5 else { return }
            maskShape = false
          }
        }
      }.simultaneousGesture(DragGesture(minimumDistance: pagerModel.config.allowsBack && pagerModel.viewDepth > 1 && pagerModel.activePage?.options.allowBackOverride != false ? 10 : .infinity, coordinateSpace: .global)
        .updating($backDragWidth) { drag, state, transaction in
          if backProgressModel.backSwipeAllowance == nil && isActive {
            backProgressModel.backSwipeAllowance = pagerModel.backGestureOverride == nil && 0.5 * drag.translation.width > abs(drag.translation.height)
          }
          
          var dragWidth: CGFloat? = nil
          if backProgressModel.backSwipeAllowance == true {
            if drag.translation.width > viewFrame.width {
              dragWidth = viewFrame.width + sqrt(abs(drag.translation.width - viewFrame.width))
            } else if drag.translation.width > 0 {
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
          backProgressModel.reset()
        }).when(backDragWidth == nil) {
          try? await Task.sleepForOneFrame()
          backProgressModel.reset()
        }.onChange(of: isActive) {
          try? await Task.sleepForOneFrame()
          backProgressModel.reset()
        }.task {
          try? await Task.sleepForOneFrame()
          try? await Task.sleepForOneFrame()
          pagerModel.pageReady(pageID)
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
    self.modifier(HelloPageBackswipe(pageID: pageID, size: pageSize))
  }
}
