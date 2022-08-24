import SwiftUI

import HelloCore

private struct HelloThemeEnvironmentKey: EnvironmentKey {
  static let defaultValue = HelloSwiftUITheme(theme: .init(theme: .dark))
}

public extension EnvironmentValues {
  var theme: HelloSwiftUITheme {
    get { self[HelloThemeEnvironmentKey.self] }
    set { self[HelloThemeEnvironmentKey.self] = newValue }
  }
}
