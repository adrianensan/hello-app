import SwiftUI

import HelloCore

public extension EnvironmentValues {
  @Entry var theme: HelloSwiftUITheme = HelloSwiftUITheme(theme: .warmLight)
  @Entry var contentShape: AnyInsettableShape? = nil
  @Entry var isActive: Bool = true
  @Entry var hasAppeared: Bool = true
  @Entry var viewID: String? = nil
  @Entry var windowFrame: CGRect = .zero
  @Entry var safeArea: EdgeInsets = EdgeInsets()
  @Entry var keyboardFrame: CGRect = .zero
  @Entry var isFullscreen: Bool = false
  @Entry var helloPagerConfig: HelloPagerConfig = HelloPagerConfig()
  @Entry var helloDismiss: @Sendable @MainActor () -> Void = {}
}

@MainActor
struct ActiveThemeObservationViewModifier: ViewModifier {
  
  @Environment(\.colorScheme) private var colorScheme: ColorScheme
  
  private var themeManager: ActiveThemeManager = .main
  
  private var currentTheme: HelloTheme {
    colorScheme == .dark
    ? themeManager.darkTheme
    : themeManager.lightTheme
  }
  
  @State private var isActive: Bool = false
  
  func body(content: Content) -> some View {
    content
      .environment(\.theme, HelloSwiftUITheme(theme: currentTheme))
      .foregroundStyle(currentTheme.baseLayer.foregroundPrimary.mainColor.swiftuiColor)
      .backgroundStyle(currentTheme.baseLayer.background.mainColor.swiftuiColor)
      .animation(.easeInOut(duration: 0.2), value: currentTheme.id)
  }
}

@MainActor
public extension View {
  func observeActiveTheme() -> some View {
    modifier(ActiveThemeObservationViewModifier())
  }
}
