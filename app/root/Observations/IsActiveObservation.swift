import SwiftUI

import HelloCore

public extension EnvironmentValues {
  @Entry var isActive: Bool = true
}

struct IsActiveObservationViewModifier: ViewModifier {
  
  private var becomeActiveNotification: Notification.Name {
#if os(macOS)
    NSApplication.didBecomeActiveNotification
#elseif os(iOS) || os(tvOS) || os(visionOS)
    UIApplication.didBecomeActiveNotification
#elseif os(watchOS)
    WKApplication.didBecomeActiveNotification
#endif
  }
  
  private var resignActiveNotification: Notification.Name {
#if os(macOS)
    NSApplication.didResignActiveNotification
#elseif os(iOS) || os(tvOS) || os(visionOS)
    UIApplication.willResignActiveNotification
#elseif os(watchOS)
    WKApplication.didEnterBackgroundNotification
#endif
  }
  
  private var willEnterForegroundNotification: Notification.Name {
#if os(macOS)
    NSApplication.didBecomeActiveNotification
#elseif os(iOS) || os(tvOS) || os(visionOS)
    UIApplication.willEnterForegroundNotification
#elseif os(watchOS)
    WKApplication.didBecomeActiveNotification
#endif
  }
  
  private var didEnterBackgroundNotification: Notification.Name {
#if os(macOS)
    NSApplication.didBecomeActiveNotification
#elseif os(iOS) || os(tvOS) || os(visionOS)
    UIApplication.didEnterBackgroundNotification
#elseif os(watchOS)
    WKApplication.didBecomeActiveNotification
#endif
  }
  
  @State private var isActive: Bool = false
  
  func body(content: Content) -> some View {
    content
      .environment(\.isActive, isActive)
      .onReceive(NotificationCenter.default.publisher(for: becomeActiveNotification)) { _ in
        Log.verbose(context: "Active State", "Did become active")
        isActive = true
      }.onReceive(NotificationCenter.default.publisher(for: resignActiveNotification)) { _ in
        Log.verbose(context: "Active State", "Will resign active")
        isActive = false
      }.onReceive(NotificationCenter.default.publisher(for: willEnterForegroundNotification)) { _ in
        Log.verbose(context: "Active State", "Will enter foreground")
        isActive = true
      }.onReceive(NotificationCenter.default.publisher(for: didEnterBackgroundNotification)) { _ in
        Log.verbose(context: "Active State", "Did enter background")
        isActive = false
      }
  }
}

public extension View {
  func observeIsActive() -> some View {
    modifier(IsActiveObservationViewModifier())
  }
}
