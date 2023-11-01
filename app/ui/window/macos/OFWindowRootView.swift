#if os(macOS)
import SwiftUI

import HelloCore

@MainActor
public struct OFWindowRootView<Content: View>: View {
  
  private var becomeActiveNotification: Notification.Name {
#if os(macOS)
    NSApplication.didBecomeActiveNotification
#else
    UIApplication.didBecomeActiveNotification
#endif
  }
  
  private var resignActiveNotification: Notification.Name {
#if os(macOS)
    NSApplication.didResignActiveNotification
#else
    UIApplication.didEnterBackgroundNotification
#endif
  }
  
  private var isActiveSystem: Bool {
#if os(macOS)
    NSApplication.shared.isActive
#else
    UIApplication.shared.applicationState == .active
#endif
  }
  
  @Environment(\.colorScheme) private var colorScheme
  
//  @PersistentState(.theme) private var orTheme
  
  @StateObject private var windowManager = OFWindowManager()
  @ObservedObject private var hoverManager: HoverManager = .main
  @ObservedObject private var themeManager: ActiveThemeManager = .main
  
  private var content: Content
  @ObservedObject private var uiProperties: UIProperties
  @State var isActive: Bool = false
  
  public init(uiProperties: UIProperties, @ViewBuilder content: () -> Content) {
    self.uiProperties = uiProperties
    self.content = content()
  }
  
  var theme: HelloTheme {
//    switch colorScheme {
//    case .dark: return orTheme.darkTheme
//    case .light: fallthrough
//    @unknown default: return orTheme.lightTheme
//    }
    
    switch colorScheme {
    case .dark: return themeManager.darkTHeme
    case .light: fallthrough
    @unknown default: return themeManager.lightTHeme
    }
  }
  
  public var body: some View {
    ZStack(alignment: .topLeading) {
      content
      
      if let popupView = windowManager.popupView {
        Button(action: { windowManager.dismissPopup() }, label: { Color.clear })
          .buttonStyle(.noStyle)
          .keyboardShortcut(.cancelAction)
          .zIndex(1)
        Color.black.opacity(0.1)
          .onLongPressGesture(minimumDuration: 0, maximumDistance: 0,
                              perform: { windowManager.dismissPopup() },
                              onPressingChanged: { _ in windowManager.dismissPopup() })
          .onTapGesture { windowManager.dismissPopup() }
          .zIndex(2)
          .transition(.opacity.animation(.easeInOut(duration: 0.1)))
        popupView
          .offset(x: windowManager.popupViewPosition.x, y: windowManager.popupViewPosition.y)
          .zIndex(3)
      }
    }.ignoresSafeArea()
      .environment(\.colorScheme, theme.isDark ? .dark : .light)
      .environment(\.currentHover, hoverManager.currentHover)
      .environment(\.theme, HelloSwiftUITheme(theme: theme))
      .environment(\.isActive, isActive)
      .environment(\.windowFrame, CGRect(origin: .zero, size: uiProperties.size))
      .environment(\.safeArea, uiProperties.safeAreaInsets)
      .environmentObject(uiProperties)
      .environmentObject(windowManager)
      .onAppear { isActive = isActiveSystem }
      .onReceive(NotificationCenter.default.publisher(for: becomeActiveNotification)) { _ in
        isActive = true
      }.onReceive(NotificationCenter.default.publisher(for: resignActiveNotification)) { _ in
        isActive = false
      }
  }
}
#endif
