#if os(macOS)
import SwiftUI

import HelloCore

class HelloAppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    NSApplication.shared.registerForRemoteNotifications()
    Task { await helloApplication.onLaunchInternal() }
  }
  
  func applicationDidBecomeActive(_ notification: Notification) {
    Task { await helloApplication.onBecameActiveInternal() }
  }
  
  func applicationDidResignActive(_ notification: Notification) {
    Task { await helloApplication.onResignActiveInternal() }
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
}
#endif
