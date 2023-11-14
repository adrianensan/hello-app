import Foundation

public enum AppInfo {
  public static let bundleID: String = Bundle.main.bundleIdentifier ?? "?"
  public static let version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
  public static let build: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
  public static let name: String = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "?"
  public static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "?"
  public static let copyright: String = Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String ?? "?"
  
  #if targetEnvironment(simulator)
  public static let isTestBuild = true
  #else
  public static let isTestBuild = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
  #endif
  
  public static var rootBundleID: String {
    bundleID
      .deletingSuffix(".widget")
      .deletingSuffix(".watchkitapp")
      .deletingSuffix(".watchkitapp.watchkitextension")
      .deletingSuffix(".messages-extension")
  }
  public static var appGroup: String { "group.\(rootBundleID)" }
  public static var iCloudContainer: String { "iCloud.\(rootBundleID)" }
}

public class HelloApplication {
  
  public static let current = HelloApplication()
  
  private init() {
    Task { await setup() }
  }
  
  private func setup() async {
    #if DEBUG
    await Persistence.save(true, for: .isDeveloper)
    #endif
    if AppInfo.isTestBuild {
      await Persistence.save(true, for: .isTester)
    }
    if let currentAppVersion = AppVersion.current {
      let previousAppVersion = await Persistence.value(.lastestVersionLaunched)
      guard currentAppVersion != previousAppVersion else { return }
      await Persistence.save(currentAppVersion, for: .lastestVersionLaunched)
    }
  }
}
