#if os(iOS)
import SwiftUI

import HelloCore

public protocol HelloAppDelegateConformable {
  associatedtype RootView: View
  var rootView: RootView { get }
  
  func applicationDidLaunch()
}

public extension HelloAppDelegateConformable {
  var rootView: Color { fatalError("No root view provided") }
  
  func applicationDidLaunch() {}
}

open class HelloAppDelegate<RootView: View>: NSObject, UIApplicationDelegate, HelloAppDelegateConformable {
  
//  public static var shared:  HelloAppDelegate?
  
  public var window: UIWindow?
  
//  override public init() {
//    super.init()
////    Hello.persistence = persistence
////    ButtonHaptics.isEnabled = { Hello.persistence.hapticsLevel != .off }
//    
////    Hello.characterView = characterView
//    //Hello.window = HelloWindow(view: HelloAppRootView(view: rootView))
//  }
  
  open var rootView: RootView { fatalError("No root view provided") }
  open var persistence: HelloPersistence { fatalError() }
  
  public final func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    applicationDidLaunch()
//    Hello.rootViewController = viewController
    
//    viewController.onBrightnessChange = { ThemeObservable.shared.handleScreenBrightnessUpdate() }
    let window = UIWindow(frame: UIScreen.main.bounds)
    let viewController = HelloRootViewController(window: window, wrappedView: rootView)
    window.rootViewController = viewController
    window.makeKeyAndVisible()
    self.window = window
    
//    Hello.cloudSyncHelper.syncAll()
//    if StoreService.main.tipProducts.isEmpty {
//      StoreService.main.refreshProducts()
//    }
    return true
  }
  
  open func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    .all
//    Hello.persistence.lockRotation ? .portrait : .allButUpsideDown
  }
}
#endif
