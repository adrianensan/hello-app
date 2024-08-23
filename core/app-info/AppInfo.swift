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
  
  public static var rootBundleID: String {
    bundleID.components(separatedBy: ".").prefix(3).joined(separator: ".")
  }
  #if os(macOS)
  public static var appGroup: String { "\(teamID).group.\(rootBundleID)" }
  #else
  public static var appGroup: String { "group.\(rootBundleID)" }
  #endif
  public static var iCloudContainer: String { "iCloud.\(rootBundleID)" }
  
  public static var helloGroup: String { "group.adrianensan.hello" }
}
