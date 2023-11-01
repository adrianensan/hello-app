import SwiftUI

import HelloCore

private struct HelloThemeEnvironmentKey: EnvironmentKey {
  #if os(iOS)
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

private struct IsActiveEnvironmentKey: EnvironmentKey {
  static let defaultValue = true
}

public extension EnvironmentValues {
  var isActive: Bool {
    get { self[IsActiveEnvironmentKey.self] }
    set { self[IsActiveEnvironmentKey.self] = newValue }
  }
}

private struct SafeAreaEnvironmentKey: EnvironmentKey {
  static let defaultValue = EdgeInsets()
}

public extension EnvironmentValues {
  var safeArea: EdgeInsets {
    get { self[SafeAreaEnvironmentKey.self] }
    set { self[SafeAreaEnvironmentKey.self] = newValue }
  }
}

private struct KeyboardFrameEnvironmentKey: EnvironmentKey {
  static let defaultValue = CGRect()
}

public extension EnvironmentValues {
  var keyboardFrame: CGRect {
    get { self[KeyboardFrameEnvironmentKey.self] }
    set { self[KeyboardFrameEnvironmentKey.self] = newValue }
  }
}

private struct WindowFrameEnvironmentKey: EnvironmentKey {
  static let defaultValue = CGRect()
}

public extension EnvironmentValues {
  var windowFrame: CGRect {
    get { self[WindowFrameEnvironmentKey.self] }
    set { self[WindowFrameEnvironmentKey.self] = newValue }
  }
}
