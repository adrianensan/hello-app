import SwiftUI

import HelloCore

private struct SafeAreaEnvironmentKey: EnvironmentKey {
  static let defaultValue = EdgeInsets()
}

public extension EnvironmentValues {
  var safeArea: EdgeInsets {
    get { self[SafeAreaEnvironmentKey.self] }
    set { self[SafeAreaEnvironmentKey.self] = newValue }
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

private struct IsFullscreenEnvironmentKey: EnvironmentKey {
  static let defaultValue = false
}

public extension EnvironmentValues {
  var isFullscreen: Bool {
    get { self[IsFullscreenEnvironmentKey.self] }
    set { self[IsFullscreenEnvironmentKey.self] = newValue }
  }
}
