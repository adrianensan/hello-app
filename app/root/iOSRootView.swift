import SwiftUI

import HelloCore

public struct HelloAppRootView<Content: View>: View {
  
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  @EnvironmentObject var uiProperties: UIProperties
  
  @ObservedObject var themeManager: ActiveThemeManager = .main
  
  @StateObject var windowModel = HelloWindowModel()
  
  @State var showHelloModal: Bool = false//Hello.isFirstLaunch
  
  var content: Content
  
  public init(_ content: Content) {
    self.content = content
  }
  
  var currentTheme: HelloTheme {
    colorScheme == .dark
    ? themeManager.darkTHeme
    : themeManager.lightTHeme
  }
  
  public var body: some View {
    ZStack {
      #if os(iOS)
      ZStack {
        content
          .compositingGroup()
          .frame(width: uiProperties.size.width, height: uiProperties.size.height)
      }.onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)) { notification in
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
          uiProperties.keyboardAnimationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0
          uiProperties.updateKeyboardFrame(to: keyboardFrame.cgRectValue)
        } else {
          uiProperties.updateKeyboardFrame(to: .zero)
        }
      }.onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)) { notification in
        uiProperties.keyboardAnimationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0
        uiProperties.updateKeyboardFrame(to: .zero)
      }
      
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
      #else
      ZStack {
        content
      }
      #endif
    }.frame(width: uiProperties.size.width, height: uiProperties.size.height)
      .environment(\.theme, HelloSwiftUITheme(theme: .init(theme: currentTheme)))
      .animation(.easeInOut(duration: 0.2), value: currentTheme.id)
      .environmentObject(windowModel)
  }
}
