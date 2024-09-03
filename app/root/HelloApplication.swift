import SwiftUI

import HelloCore

@MainActor
var helloApplication: (any HelloApplication)! = nil

@MainActor
public struct HelloScene: Sendable {
  
  @available(visionOS 1.0, *)
  public enum HelloImmersiveSceneType: Sendable {
    case mixed
    case full
  }
  
  public enum HelloSceneType: Sendable {
    case window
    #if os(visionOS)
    @available(visionOS 1.0, *)
    case volumetric
    @available(visionOS 1.0, *)
    case immersive(HelloImmersiveSceneType)
    #endif
    
    
    #if os(iOS) || os(visionOS)
    var systemRole: UISceneSession.Role {
      #if os(iOS)
      switch self {
      case .window:
          .windowApplication
      }
      #elseif os(visionOS)
      switch self {
      case .window:
        .windowApplication
      case .volumetric:
        .windowApplicationVolumetric
      case .immersive:
        .immersiveSpaceApplication
      }
      #endif
    }
    #endif
  }
  
  var type: HelloSceneType
  #if os(visionOS)
  var showBackground: Bool
  #endif
  var rootView: () -> AnyView
  
#if os(visionOS)
  public init(type: HelloSceneType = .window,
              showBackground: Bool = true,
              rootView: @escaping () -> some View) {
    self.type = type
    self.showBackground = showBackground
    self.rootView = { AnyView(rootView()) }
  }
#else
  public init(type: HelloSceneType = .window,
              rootView: @escaping () -> some View) {
    self.type = type
    self.rootView = { AnyView(rootView()) }
  }
#endif
}

@MainActor
public protocol HelloApplication: AnyObject {
  
  static func load() -> Self
  
  /// Do any work needed before the application is created
  func onLaunch()
  func onTerminate()
  
  func onBecameActive() async
  func onResignActive() async
  func onBackgrounded() async
  
  func versionUpdated(from previousVersion: AppVersion, to newVersion: AppVersion) async
  func onFirstLaunch() async
  
  func open(url: HelloURL) -> Bool
  func handle(notification: [AnyHashable: Any])
  
  var supportsNotifications: Bool { get }
  
  #if os(iOS)
  func touchesUpdate(to touches: [HelloTouch])
  #elseif os(macOS)
  var terminatesWhenAllWindowsClosed: Bool { get }
  func onDockIconClick()
  #endif
  
  var rootView: AnyView { get }
  
  #if os(visionOS)
  associatedtype Scenes: Scene
  
  @SceneBuilder
  static var scene: Scenes { get }
  #endif

}

#if os(watchOS)
import WatchKit
#endif

public extension HelloApplication {
  
  static func manualStart() {
    guard helloApplication == nil else { return }
    setup()
    helloApplication.onLaunchInternal()
  }
  
  private static func setup() {
    guard helloApplication == nil else { return }
    CrashHandler.setup()
    helloApplication = load()
  }
  
  static func main() {
    guard helloApplication == nil else { return }
    setup()
    
    #if os(iOS) || os(tvOS)
    _ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, NSStringFromClass(HelloUIApplication.self), NSStringFromClass(HelloAppDelegate.self))
    #elseif os(visionOS)
    HelloSwiftUIApp<Self>.main()
    #elseif os(macOS)
    let appDelegate = HelloAppDelegate()
    NSApplication.shared.delegate = appDelegate
    _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    #elseif os(watchOS)
//    WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: NSStringFromClass(HelloRootViewController.self), context: [:] as AnyObject)])
    HelloSwiftUIWatchOSApp.main()
//    HelloRootViewController().becomeCurrentPage()
//    _ = WKApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, NSStringFromClass(HelloAppDelegate.self))
    #endif
  }
  
  func onLaunch() {}
  func onTerminate() {}
  
  func onBecameActive() async {}
  func onResignActive() async {}
  func onBackgrounded() async {}
  
  var supportsNotifications: Bool { false }
  
  func versionUpdated(from previousVersion: AppVersion, to newVersion: AppVersion) {}
  func onFirstLaunch() {}
  
  func open(url: HelloURL) -> Bool { false }
  func handle(notification: [AnyHashable: Any]) { }
  #if os(iOS)
  func touchesUpdate(to touches: [HelloTouch]) {}
  #elseif os(macOS)
  var terminatesWhenAllWindowsClosed: Bool { true }
  func onDockIconClick() {}
  #endif
}

extension HelloApplication {
  func onLaunchInternal() {
    Task {
#if DEBUG
      await Persistence.save(true, for: .isDeveloper)
#endif
      if AppInfo.isTestBuild {
        await Persistence.save(true, for: .isTester)
        await Persistence.atomicUpdate(for: .unlockedAppIcons) {
          var unlockedAppIcons = $0
          if unlockedAppIcons.contains("betaTester") {
            unlockedAppIcons.insert("betaTester")
          }
          return unlockedAppIcons
        }
      }
      await Persistence.atomicUpdate(for: .installedApps) {
        var installedApps = $0
        installedApps.insert(AppInfo.rootBundleID)
        return installedApps
      }
      Log.verbose("Device ID: \(await Persistence.value(.deviceID))")
      if let currentAppVersion = AppVersion.current {
        let previousAppVersion = await Persistence.value(.lastestVersionLaunched)
        if currentAppVersion != previousAppVersion {
          await Persistence.save(currentAppVersion, for: .lastestVersionLaunched)
          if let previousAppVersion {
            await helloApplication.versionUpdated(from: previousAppVersion, to: currentAppVersion)
          } else {
            await helloApplication.onFirstLaunch()
          }
        }
      }      
    }
    
    onLaunch()
    _ = Log.logger
  }
  
  func onTerminateInternal() {
    try? Persistence.wipeFiles(in: .temporary, notAccessedWithin: .secondsInDay)
    Persistence.unsafeSave(.now, for: .lastestDateLaunched)
    Log.terminate()
    onTerminate()
  }
  
  func onBecameActiveInternal() async {
    await onBecameActive()
  }
  
  func onResignActiveInternal() async {
    await onResignActive()
  }
  
  func onBackgroundedInternal() async {
    await onBackgrounded()
  }
  
  #if os(iOS)
  func touchesUpdateInternal(to touches: [HelloTouch]) {
    TouchesModel.main.activeTouches = touches
    touchesUpdate(to: touches)
  }
  #endif
}
