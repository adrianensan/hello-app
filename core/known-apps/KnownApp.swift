import Foundation

public enum HelloAppPlatform: String, Identifiable, Codable, Sendable {
  case iOS
  case iMessage
  case watchOS
  case visionOS
  case macOS
  
  public var id: String { rawValue }
}

public struct KnownApp: Identifiable, Equatable, Codable, Sendable {
  public var id: String
  public var bundleID: String
  public var name: String
  public var url: String
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
