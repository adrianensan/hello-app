#if os(macOS)
import SwiftUI

import HelloCore

class HelloAppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApplication.shared.registerForRemoteNotifications()
    helloApplication.onLaunchInternal()
  }
  
  func applicationDidBecomeActive(_ notification: Notification) {
    Task { await helloApplication.onBecameActiveInternal() }
  }
  
  func applicationDidResignActive(_ notification: Notification) {
    Task { await helloApplication.onResignActiveInternal() }
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    helloApplication.terminatesWhenAllWindowsClosed
  }
  
  func applicationWillTerminate(_ notification: Notification) {
    helloApplication.onTerminateInternal()
  }
  
  func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
    Log.verbose("Remote notification received")
    helloApplication.handle(notification: userInfo)
  }
  
  func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Log.verbose("Successfully registered for remote notifications")
  }
  
  func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
    Log.error("Failed to register for remote notifications: \(error.localizedDescription)")
  }
  
  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    for window in sender.windows where window.canBecomeKey {
      window.makeKeyAndOrderFront(self)
    }
    helloApplication.onDockIconClick()
    return false
  }
}
#endif
