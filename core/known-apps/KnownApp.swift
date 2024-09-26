import Foundation

public enum HelloAppPlatform: String, Identifiable, Codable, Sendable {
  case iOS
  case iMessage
  case watchOS
  case visionOS
  case macOS
  
  public var id: String { rawValue.lowercased() }
  
  public var name: String {
    rawValue
  }
}

public extension [HelloAppPlatform] {
  var string: String {
    reduce("") {
      $0 + ($0.isEmpty ? "" : ", ") + $1.name
    }
  }
}

public struct KnownApp: Identifiable, Hashable, Codable, Sendable {
  public var id: String
  public var int: Int
  public var bundleID: String
  public var appleID: String
  public var name: String
  public var description: String = ""
  public var platforms: [HelloAppPlatform]
}

public extension KnownApp {
  public static var all: [KnownApp] {
    var apps: [KnownApp] = [.helloPodcasts, .helloPasswords, .helloSolitaire, .helloMinesweeper, .helloEmoji]
    if let currentApp = apps.first(where: { $0.bundleID == AppInfo.rootBundleID }) {
      apps.removeAll { $0.bundleID == currentApp.bundleID }
      apps.insert(currentApp, at: 0)
    }
    return apps
  }
  
  public static func app(for bundleID: String) -> KnownApp? {
    all.first { $0.bundleID == bundleID }
  }
}
