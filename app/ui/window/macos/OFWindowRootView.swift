#if os(macOS)
import SwiftUI

import HelloCore

public struct OFWindowRootView<Content: View>: View {
  
  @Environment(\.colorScheme) private var colorScheme
  
//  @PersistentState(.theme) private var orTheme
  
  @StateObject private var windowManager = OFWindowManager()
  @ObservedObject private var hoverManager: HoverManager = .main
  @ObservedObject private var themeManager: ActiveThemeManager = .main
  
  private var content: Content
  @State private var uiProperties: UIProperties
  
  public init(uiProperties: UIProperties, @ViewBuilder content: () -> Content) {
    self._uiProperties = State(initialValue: uiProperties)
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
      .environment(\.theme, HelloSwiftUITheme(theme: .init(theme: theme)))
      .environmentObject(uiProperties)
      .environmentObject(windowManager)
  }
}
#endif
