#if os(macOS)
import SwiftUI

import HelloCore

@MainActor
class HelloAppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    
  }
  
  func applicationDidBecomeActive(_ notification: Notification) {
    Task { await helloApplication.becameActive() }
  }
  
  func applicationDidResignActive(_ notification: Notification) {
    Task { await helloApplication.lostActive() }
  }
  
  func applicationWillTerminate(_ notification: Notification) {
    
  }
}
#endif
