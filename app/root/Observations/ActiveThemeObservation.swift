import SwiftUI

import HelloCore

private struct HelloThemeEnvironmentKey: EnvironmentKey {
#if os(iOS) || os(visionOS)
  static let defaultValue = HelloSwiftUITheme(theme: .dark)
#else
  static let defaultValue = HelloSwiftUITheme(theme: .darkBlur)
#endif
}

public extension EnvironmentValues {
  var theme: HelloSwiftUITheme {
    get { self[HelloThemeEnvironmentKey.self] }
    set { self[HelloThemeEnvironmentKey.self] = newValue }
  }
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
      .animation(.easeInOut(duration: 0.2), value: currentTheme.id)
  }
}

@MainActor
public extension View {
  func observeActiveTheme() -> some View {
    modifier(ActiveThemeObservationViewModifier())
  }
}
