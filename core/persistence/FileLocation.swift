import Foundation

public enum FilePersistenceLocation: Hashable, Identifiable, Sendable {
  case document
  case applicationSupport
  case appGroup
  case helloShared
  case temporary
  case cache
  case downloads
  case custom(String)
  
  public static var allCases: [FilePersistenceLocation] { [
    .document,
    .applicationSupport,
    .appGroup,
    .helloShared,
    .temporary,
    .cache,
    .downloads
  ]}
  
  public var id: String {
    switch self {
    case .document: "document"
    case .applicationSupport: "support"
    case .appGroup: "app-group"
    case .helloShared: "hello-shared"
    case .temporary: "temporary"
    case .cache: "cache"
    case .downloads: "downloads"
    case .custom(let url): url
    }
  }
  
  public var name: String {
    switch self {
    case .document: "Documents"
    case .applicationSupport: "Application Support"
    case .appGroup: "App Group"
    case .helloShared: "Hello"
    case .temporary: "Temporary"
    case .cache: "Cache"
    case .downloads: "Downloads"
    case .custom(let url): url
    }
  }
  
  public var url: URL? {
    switch self {
    case .document:
      .documentsDirectory.appending(component: AppInfo.bundleID, directoryHint: .isDirectory)
    case .applicationSupport:
      .applicationSupportDirectory.appending(component: AppInfo.bundleID, directoryHint: .isDirectory)
    case .appGroup:
      FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppInfo.appGroup)
    case .helloShared:
      FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppInfo.sharedHelloGroup)
    case .temporary:
      .temporaryDirectory.appending(component: AppInfo.bundleID, directoryHint: .isDirectory)
    case .cache:
      .cachesDirectory.appending(component: AppInfo.bundleID, directoryHint: .isDirectory)
    case .downloads:
      .downloadsDirectory.appending(component: AppInfo.bundleID, directoryHint: .isDirectory)
    case .custom(let url):
      URL(string: url)?.appending(component: AppInfo.bundleID, directoryHint: .isDirectory)
    }
  }
  public var newURL: URL? {
    switch self {
    case .document:
        .documentsDirectory
    case .applicationSupport:
        .applicationSupportDirectory
    case .appGroup:
      FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppInfo.appGroup)
    case .helloShared:
      FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppInfo.sharedHelloGroup)
    case .temporary:
        .temporaryDirectory
    case .cache:
        .cachesDirectory
    case .downloads:
        .downloadsDirectory
    case .custom(let url):
      URL(string: url)
    }
  }
}
