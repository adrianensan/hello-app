import SwiftUI

import HelloCore

private struct HelloThemeEnvironmentKey: EnvironmentKey {
  #if os(iOS)
  static let defaultValue = HelloSwiftUITheme(theme: .init(theme: .dark))
  #else
  static let defaultValue = HelloSwiftUITheme(theme: .init(theme: .darkBlur))
  #endif
}

public extension EnvironmentValues {
  var theme: HelloSwiftUITheme {
    get { self[HelloThemeEnvironmentKey.self] }
    set { self[HelloThemeEnvironmentKey.self] = newValue }
  }
}
