import Foundation

public enum AppInfo {
  public static let teamID = "QS4LCPSUAU"
  public static let bundleID: String = Bundle.main.bundleIdentifier ?? "?"
  public static let version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
  public static let build: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
  public static let name: String = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "?"
  public static let displayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? name
  public static let copyright: String = Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String ?? "?"
  
  #if DEBUG || targetEnvironment(simulator)
  public static let isTestBuild = true
  #else
  public static let isTestBuild = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
  #endif
  
  public static var sharedBundleID: String { "com.adrianensan.hello" }
  public static var rootBundleID: String {
    bundleID.components(separatedBy: ".").prefix(3).joined(separator: ".")
  }
  #if os(macOS)
  public static var appGroup: String { "\(teamID).group.\(rootBundleID)" }
  public static var sharedHelloGroup: String { "\(teamID).group.\(sharedBundleID)" }
  #else
  public static var appGroup: String { "group.\(rootBundleID)" }
  public static var sharedHelloGroup: String { "group.\(sharedBundleID)" }
  #endif
  public static var iCloudContainer: String { "iCloud.\(rootBundleID)" }
  public static var sharedHelloICloudContainer: String { "iCloud.\(sharedBundleID)" }
  
  public static var fullVersionString: String {
    #if DEBUG || targetEnvironment(simulator)
    "\(AppInfo.version) (\(AppInfo.build)) [DEBUG]"
    #else
    if AppInfo.isTestBuild {
      "\(AppInfo.version) (\(AppInfo.build)) [TestFlight]"
    } else {
      AppInfo.version
    }
    #endif
  }
}
