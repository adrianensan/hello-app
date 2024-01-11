import SwiftUI

import HelloCore

var helloApplication: (any HelloApplicationn)! = nil

@MainActor
public protocol HelloApplicationn: AnyObject {
  
  static func load() -> Self
  
  /// Do any work neede before the application is created
  func onLaunch() async
  
  func becameActive() async
  func lostActive() async
  
  func versionUpdated(from previousVersion: AppVersion, to newVersion: AppVersion) async
  func firstLaunch() async
  
  func view() -> AnyView
}

#if os(watchOS)
import WatchKit
#endif

public extension HelloApplicationn {
  
  static func manualStart() {
    guard helloApplication == nil else { return }
    setup()
    Task {
      await helloApplication.onLaunchInternal()
    }
  }
  
  private static func setup() {
    guard helloApplication == nil else { return }
    print("setup")
    _ = Log.logger
    CrashHandler.setup()
    helloApplication = load()
  }
  
  static func main() {
    guard helloApplication == nil else { return }
    setup()
    
    #if os(iOS) || os(tvOS) || os(visionOS)
    _ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(HelloAppDelegate.self))
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
  
  func becameActive() async {}
  func lostActive() async {}
  
  func versionUpdated(from previousVersion: AppVersion, to newVersion: AppVersion) {}
  func firstLaunch() {}
}

extension HelloApplicationn {
  func onLaunchInternal() async {
#if DEBUG
    await Persistence.save(true, for: .isDeveloper)
#endif
    if AppInfo.isTestBuild {
      await Persistence.save(true, for: .isTester)
    }
    if let currentAppVersion = AppVersion.current {
      let previousAppVersion = await Persistence.value(.lastestVersionLaunched)
      if currentAppVersion != previousAppVersion {
        await Persistence.save(currentAppVersion, for: .lastestVersionLaunched)
        if let previousAppVersion {
          await helloApplication.versionUpdated(from: previousAppVersion, to: currentAppVersion)
        } else {
          await helloApplication.firstLaunch()
        }
      }
    }
    
    await onLaunch()
  }
  
  func becameActiveInternal() async {
    await becameActive()
  }
  
  func lostActiveInternal() async {
    await lostActive()
  }
}
