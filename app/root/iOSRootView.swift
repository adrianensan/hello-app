#if os(iOS) || os(tvOS) || os(visionOS)
import SwiftUI

import HelloCore

public struct HelloAppRootView<Content: View>: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(UIProperties.self) private var uiProperties
  
  @Persistent(.showTouches) private var showTouches
  
  private var content: @MainActor () -> Content
  
  public init(_ content: @escaping @MainActor () -> Content) {
    self.content = content
  }
  
  public var body: some View {
    ZStack {
      content()
        .compositingGroup()
//        .grayscale(windowModel.popupViews.isEmpty ? 0 : 0.8)
        .blur(radius: windowModel.blurBackgroundForPopup && !windowModel.popupViews.isEmpty ? 2 : 0)
        .animation(.easeInOut(duration: 0.24), value: !windowModel.popupViews.isEmpty)
      
      if !windowModel.popupViews.isEmpty {
        ForEach(windowModel.popupViews) { popupView in
          popupView.view()
            .id(popupView.id)
            .zIndex(3 + 0.1 * Double((windowModel.popupViews.firstIndex(where: { $0.id == popupView.id }) ?? 0)))
            .transition(.asymmetric(insertion: .opacity.animation(.linear(duration: 0)),
                                    removal: .opacity.animation(.linear(duration: 0.1).delay(0.4))))
            .allowsHitTesting(windowModel.popupViews.contains(where: { $0.id == popupView.id }))
        }
      }
      
      #if os(iOS)
      if showTouches {
        TouchesVisualizer()
          .zIndex(10)
      }
      #endif
    }.environment(\.safeArea, uiProperties.safeAreaInsets)
      .observeWindowFrame()
      .observeKeyboardFrame()
      .observeIsActive()
      .observeActiveTheme()
  }
}
#endif
