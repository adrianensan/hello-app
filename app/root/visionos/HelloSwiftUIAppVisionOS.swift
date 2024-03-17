#if os(visionOS)
import SwiftUI

struct HelloSwiftUIApp<HelloApp: HelloApplication>: App {
  
  @UIApplicationDelegateAdaptor(HelloAppDelegate.self) private var appDelegate
  
  var body: HelloApp.Scenes {
    HelloApp.scene
  }
}

#endif
