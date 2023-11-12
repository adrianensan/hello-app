import SwiftUI

import HelloCore

@MainActor
public struct HelloAppRootView<Content: View>: View {
  
  private var becomeActiveNotification: Notification.Name {
    #if os(macOS)
    NSApplication.didBecomeActiveNotification
    #elseif os(iOS)
    UIApplication.didBecomeActiveNotification
    #elseif os(watchOS)
    WKApplication.didBecomeActiveNotification
    #endif
  }
  
  private var resignActiveNotification: Notification.Name {
    #if os(macOS)
    NSApplication.didResignActiveNotification
    #elseif os(iOS)
    UIApplication.didEnterBackgroundNotification
    #elseif os(watchOS)
    WKApplication.didEnterBackgroundNotification
    #endif
  }
  
  private var isActiveSystem: Bool {
    #if os(macOS)
    NSApplication.shared.isActive
    #elseif os(iOS)
    UIApplication.shared.applicationState == .active
    #else
    true
    #endif
  }
  
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  @Environment(HelloWindowModel.self) private var windowModel
  @EnvironmentObject var uiProperties: UIProperties
  
  @ObservedObject var themeManager: ActiveThemeManager = .main
  
  @State var showHelloModal: Bool = false//Hello.isFirstLaunch
  @State var isActive: Bool = false
  
  var content: Content
  
  public init(_ content: Content) {
    self.content = content
  }
  
  var currentTheme: HelloTheme {
    colorScheme == .dark
    ? themeManager.darkTHeme
    : themeManager.lightTHeme
  }
  
  @State var keyboardFrame: CGRect?
  
  public var body: some View {
    ZStack {
      #if os(iOS)
      ZStack {
        content
//          .frame(width: uiProperties.size.width, height: uiProperties.size.height)
      }.environment(\.keyboardFrame, uiProperties.keyboardFrame)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)) { notification in
          if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            uiProperties.keyboardAnimationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0
            uiProperties.updateKeyboardFrame(to: keyboardFrame.cgRectValue)
          } else {
            uiProperties.updateKeyboardFrame(to: .zero)
          }
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)) { notification in
          uiProperties.keyboardAnimationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0
          uiProperties.updateKeyboardFrame(to: .zero)
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { notification in
          isActive = false
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { notification in
          isActive = true
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
    }
//    .frame(width: uiProperties.size.width, height: uiProperties.size.height)
      .environment(\.theme, HelloSwiftUITheme(theme: currentTheme))
      .environment(\.isActive, isActive)
      .environment(\.windowFrame, CGRect(origin: .zero, size: uiProperties.size))
      .environment(\.safeArea, uiProperties.safeAreaInsets)
      .animation(.easeInOut(duration: 0.2), value: currentTheme.id)
      .environment(windowModel)
  }
}
