#if os(tvOS)
import SwiftUI

import HelloCore

class HelloAppDelegate: NSObject, UIApplicationDelegate {
  
  public var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    if !application.supportsMultipleScenes {
      let window = UIWindow()
      let viewController = HelloRootViewController(window: window, wrappedView: helloApplication.view())
      window.rootViewController = viewController
      window.makeKeyAndVisible()
      self.window = window
    }
    
    return true
  }
  
  public func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    let config = UISceneConfiguration(name: "helooo", sessionRole: connectingSceneSession.role)
    config.delegateClass = SceneDelegate.self
    return config
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    
  }
}

class SceneDelegate: NSObject, UISceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else {
      Log.error(context: "App Delegate", "Expected UIWindowScene in willConnectTo")
      return
    }
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = HelloRootViewController(window: window, wrappedView: helloApplication.view())
    window.makeKeyAndVisible()
    self.window = window
  }
}
#endif
