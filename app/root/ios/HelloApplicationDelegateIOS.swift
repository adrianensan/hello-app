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
    application.registerForRemoteNotifications()
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
  
  func applicationWillTerminate(_ application: UIApplication) {
    helloApplication.onTerminateInternal()
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    Task { await helloApplication.becameActiveInternal() }
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    Task { await helloApplication.lostActiveInternal() }
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
    helloApplication.open(url: HelloURL(string: url.absoluteString))
  }
  
  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    .all
//    Hello.persistence.lockRotation ? .portrait : .allButUpsideDown
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
    Log.verbose("Remote notification received")
    helloApplication.handle(notification: userInfo)
    return .noData
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Log.verbose("Successfully registered for remote notifications")
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
    Log.error("Failed to register for remote notifications: \(error.localizedDescription)")
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
  
  public func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
    for urlContext in urlContexts {
      helloApplication.open(url: HelloURL(string: urlContext.url.absoluteString))
    }
  }
  
  public func sceneDidBecomeActive(_ scene: UIScene) {
    Task { await helloApplication.becameActiveInternal() }
  }
  
  public func sceneDidEnterBackground(_ scene: UIScene) {
    Task { await helloApplication.lostActiveInternal() }
  }
  
//  public func sceneWillEnterForeground(_ scene: UIScene) {
//    Task { await helloApplication.becameActiveInternal() }
//  }
}
#endif
