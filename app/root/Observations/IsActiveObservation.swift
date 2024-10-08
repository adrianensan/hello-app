import SwiftUI

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
  
  private var isActiveSystem: Bool {
#if os(macOS)
    NSApplication.shared.isActive
#elseif os(iOS) || os(tvOS) || os(visionOS)
    UIApplication.shared.applicationState == .active
#elseif os(watchOS)
    true
#endif
  }
  
  @State var isActive: Bool = false
  
  func body(content: Content) -> some View {
    content
      .environment(\.isActive, isActive)
      .onReceive(NotificationCenter.default.publisher(for: resignActiveNotification)) { notification in
        isActive = false
      }.onReceive(NotificationCenter.default.publisher(for: becomeActiveNotification)) { notification in
        isActive = true
      }
  }
}

public extension View {
  func observeIsActive() -> some View {
    modifier(IsActiveObservationViewModifier())
  }
}
