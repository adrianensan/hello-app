#if os(visionOS)
import SwiftUI

import HelloCore

class HelloAppDelegate: NSObject, UIApplicationDelegate {
  
  public var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    if !application.supportsMultipleScenes {
      let window = UIWindow()
      let viewController = HelloRootViewController(window: window, wrappedView: { helloApplication.rootView })
      window.rootViewController = viewController
      window.makeKeyAndVisible()
      self.window = window
    }
    
    return true
  }
  
  public func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    UISceneConfiguration(name: connectingSceneSession.configuration.name ?? options.userActivities.first?.activityType, sessionRole: .windowApplication)
//    let configName = connectingSceneSession.configuration.name ?? options.userActivities.first?.activityType
//    guard let helloScene = helloApplication.scenes[configName] else {
//      Log.error("No scene found for \(configName)")
//      return UISceneConfiguration(name: configName, sessionRole: .windowApplication)
//    }
//    print("activating scene for \(configName)")
//    let config = UISceneConfiguration(name: configName, sessionRole: helloScene.type.systemRole)
//    config.delegateClass = SceneDelegate.self
//    return config
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    
  }
}

class SceneDelegate: NSObject, UISceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//    let configName = session.configuration.name ?? connectionOptions.userActivities.first?.activityType
//    guard let helloScene = helloApplication.scenes[configName] else {
//      Log.error("No scene found for \(configName)")
//      return
//    }
//
//    guard var windowScene = scene as? UIWindowScene else {
//      Log.error("Expected UIWindowScene in willConnectTo", context: "App Delegate")
//      return
//    }
//
//    let window = UIWindow(windowScene: windowScene)
//    self.window = window
//    window.rootViewController = HelloRootViewController(window: window, wrappedView: helloScene.rootView())
//    window.makeKeyAndVisible()
  }
}
#endif
