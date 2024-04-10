#if os(iOS) || os(tvOS) || os(visionOS)
import SwiftUI

import HelloCore

@MainActor
public struct HelloAppRootView<Content: View>: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(UIProperties.self) private var uiProperties
  
  @State private var showHelloModal: Bool = false//Hello.isFirstLaunch
  
  private var content: () -> Content
  
  public init(_ content: @escaping () -> Content) {
    self.content = content
  }
  
  public var body: some View {
    ZStack {
      content()
        .compositingGroup()
        .blur(radius: windowModel.blurBackgroundForPopup && (windowModel.alertView != nil || !windowModel.popupViews.isEmpty) ? 2 : 0)
        .animation(.easeInOut(duration: 0.24), value: windowModel.alertView != nil || !windowModel.popupViews.isEmpty)
//          .frame(width: uiProperties.size.width, height: uiProperties.size.height)
      
      if !windowModel.popupViews.isEmpty {
        ForEach(windowModel.popupViews) { popupView in
          popupView.view()
            .id(popupView.instanceID)
            .zIndex(3 + 0.1 * Double((windowModel.popupViews.firstIndex(where: { $0.id == popupView.id }) ?? 0)))
            .transition(.asymmetric(insertion: .opacity.animation(.linear(duration: 0)),
                                    removal: .opacity.animation(.linear(duration: 0.1).delay(0.4))))
            .allowsHitTesting(windowModel.popupViews.contains(where: { $0.id == popupView.id }))
        }
      }
      
      if let alertView = windowModel.alertView {
        alertView
          .id(windowModel.alertViewID)
          .zIndex(4)
          .transition(.asymmetric(insertion: .opacity.animation(.linear(duration: 0)),
                                  removal: .opacity.animation(.linear(duration: 0.1).delay(0.4))))
          .allowsHitTesting(windowModel.alertView != nil)
      }
    }
//    .frame(width: uiProperties.size.width, height: uiProperties.size.height)
      .environment(\.windowFrame, windowModel.window?.frame ?? CGRect(origin: .zero, size: uiProperties.size))
      .environment(\.safeArea, uiProperties.safeAreaInsets)
      .observeKeyboardFrame()
      .observeIsActive()
      .observeActiveTheme()
  }
}
#endif
