#if os(iOS)
import SwiftUI
import Intents

import HelloCore

@MainActor
class HelloAppDelegate: NSObject, UIApplicationDelegate {
  
//  public static var shared: HelloAppDelegate?
  
  public var window: UIWindow?
  
//  override public init() {
//    super.init()
////    Hello.persistence = persistence
////    ButtonHaptics.isEnabled = { Hello.persistence.hapticsLevel != .off }
//    
////    Hello.characterView = characterView
//    //Hello.window = HelloWindow(view: HelloAppRootView(view: rootView))
//  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    Hello.rootViewController = viewController
//    viewController.onBrightnessChange = { ThemeObservable.shared.handleScreenBrightnessUpdate() }
    if !application.supportsMultipleScenes {
      let window = UIWindow()
      let viewController = HelloRootViewController(window: window, wrappedView: helloApplication.view())
      window.rootViewController = viewController
      window.makeKeyAndVisible()
      self.window = window
    }
    Task {
      await helloApplication.onLaunchInternal()
    }
    
//    Hello.cloudSyncHelper.syncAll()
//    if StoreService.main.tipProducts.isEmpty {
//      StoreService.main.refreshProducts()
//    }
    return true
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    Task { await helloApplication.becameActive() }
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    Task { await helloApplication.lostActive() }
  }
  
  public func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    config.delegateClass = SceneDelegate.self
    return config
  }
  
  func application(_ application: UIApplication,
                   open url: URL,
                   options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    helloApplication.open(url: url)
  }
  
  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    .all
//    Hello.persistence.lockRotation ? .portrait : .allButUpsideDown
  }
}

public class SceneDelegate: NSObject, UISceneDelegate {
  
  public var window: UIWindow?
  
  public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = HelloRootViewController(window: window, wrappedView: helloApplication.view())
    window.makeKeyAndVisible()
    self.window = window
  }
}
#endif
