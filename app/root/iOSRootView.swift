import SwiftUI

import HelloCore

@MainActor
public struct HelloAppRootView<Content: View>: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  @EnvironmentObject var uiProperties: UIProperties  
  
  @State var showHelloModal: Bool = false//Hello.isFirstLaunch
  
  var content: Content
  
  public init(_ content: Content) {
    self.content = content
  }
  
  public var body: some View {
    ZStack {
      content
//          .frame(width: uiProperties.size.width, height: uiProperties.size.height)
      
      if let popupView = windowModel.popupView {
        popupView
          .id(windowModel.popupViewID)
          .zIndex(3)
          .transition(.asymmetric(insertion: .opacity.animation(.linear(duration: 0)),
                                  removal: .opacity.animation(.linear(duration: 0.1).delay(0.4))))
          .allowsHitTesting(windowModel.popupView != nil)
      }
      
      if let alertView = windowModel.alertView {
        alertView
          .id(windowModel.popupViewID)
          .zIndex(4)
          .transition(.asymmetric(insertion: .opacity.animation(.linear(duration: 0)),
                                  removal: .opacity.animation(.linear(duration: 0.1).delay(0.4))))
      }
    }
//    .frame(width: uiProperties.size.width, height: uiProperties.size.height)
      .environment(\.windowFrame, CGRect(origin: .zero, size: uiProperties.size))
      .environment(\.safeArea, uiProperties.safeAreaInsets)
      .observeKeyboardFrame()
      .observeIsActive()
      .observeIsActive()
      .environment(windowModel)
  }
}
