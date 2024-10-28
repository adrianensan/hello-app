import Foundation
import Observation

public enum DefaultsPersistenceSuite: Hashable, Sendable, CaseIterable {
  case standard
  case appGroup
  case helloShared
  case custom(String)
  
  public var id: String {
    switch self {
    case .standard: "standard"
    case .appGroup: "appGroup"
    case .helloShared: "hello"
    case .custom(let suite): suite
    }
  }
  
  public var name: String {
    switch self {
    case .standard: "Standard"
    case .appGroup: "App Group"
    case .helloShared: "Hello"
    case .custom(let suite): suite
    }
  }
  
  public static var allCases: [DefaultsPersistenceSuite] { [
    .standard,
    .appGroup,
    .helloShared,
  ]}
  
  public var userDefaults: UserDefaults? {
    switch self {
    case .standard:
      return .standard
    case .appGroup:
      if let appGroupDefaults = UserDefaults(suiteName: AppInfo.appGroup) {
        return appGroupDefaults
      } else {
        Log.fatal(context: "Persistence", "Failed to create UserDefaults for app group, please ensure \(AppInfo.appGroup) is added as an App Group")
        return nil
      }
    case .helloShared:
      if let helloDefaults = UserDefaults(suiteName: AppInfo.sharedHelloGroup) {
        return helloDefaults
      } else {
        Log.fatal(context: "Persistence", "Failed to create UserDefaults for share Hello, please ensure com.adrianensan.hello is added as an App Group")
        return nil
      }
    case .custom(let suiteName):
      if let helloDefaults = UserDefaults(suiteName: suiteName) {
        return  helloDefaults
      } else {
        Log.fatal(context: "Persistence", "Failed to create UserDefaults for \(suiteName)")
        return nil
      }
    }
  }
}

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

public enum PersistenceLocationType: Sendable {
  case defaults
  case file
  case keychain
  case memory
}

public enum PersistenceType: Sendable {
  
  case defaults(suite: DefaultsPersistenceSuite = .standard, key: String)
  case file(location: FilePersistenceLocation, path: String)
  case keychain(key: String, appGroup: Bool, isBiometricallyLocked: Bool = false)
  case memory(key: String)
  
  public var id: String {
    switch self {
    case .defaults(let suite, let key): "defaults-\(suite.id)-\(key)"
    case .file(let location, let path): "file-\(location.id)-\(path)"
    case .keychain(let key, let appGroup, let isBiometricallyLocked): "keychain-\(key)\(isBiometricallyLocked ? "-bio" : "")"
    case .memory(let key): "memory-\(key)"
    }
  }
  
  public var type: PersistenceLocationType {
    switch self {
    case .defaults: .defaults
    case .file: .file
    case .keychain: .keychain
    case .memory: .memory
    }
  }
}

extension Never: PersistenceProperty {
  
  public var defaultValue: Never { fatalError("") }
  
  public var location: PersistenceType { .memory(key: "never") }
}

public protocol PersistenceProperty<Value>: Sendable {
  
  associatedtype Value: Codable & Sendable
  associatedtype OldProperty: PersistenceProperty = Never
  
  var defaultValue: Value { get }
  func defaultValue(for mode: PersistenceMode) -> Value
  
  var demoIsSet: Bool { get }
  
  var allowedInDemoMode: Bool { get }
  
  var location: PersistenceType { get }
  
  var isDeprecated: Bool { get }
  
  var allowCache: Bool { get }
  
  var persistDefaultValue: Bool { get }
  
  func cleanup(value: Value) -> Value
  
  var oldProperty: OldProperty? { get }
  
  func migrate(from oldValue: OldProperty.Value) -> Value?
}

extension PersistenceProperty {
  
  public func cleanup(value: Value) -> Value { value }
  
  public func defaultValue(for mode: PersistenceMode) -> Value {
    defaultValue
  }
  
  public var demoIsSet: Bool { false }
  
  public var allowedInDemoMode: Bool { false }
  
  public var allowCache: Bool {
    switch location {
    case .defaults: true
    case .file: false
    case .keychain: true
    case .memory: true
    }
  }
  public var persistDefaultValue: Bool { false }
  public var isDeprecated: Bool { false }
  public var id: String { location.id }
  
  public var oldProperty: OldProperty? { nil }
  public func migrate(from oldValue: OldProperty.Value) -> Value? { nil }
  
  public var forcedNewFileURL: URL? {
    switch location {
    case .defaults: nil
    case .file(let location, let path):
      location.newURL?.appending(component: path)
    case .keychain: nil
    case .memory: nil
    }
  }
  
  public var fileURL: URL? {
    switch location {
    case .defaults: nil
    case .file(let location, let path):
      if let url = location.newURL?.appending(component: path),
         FileManager.default.fileExists(atPath: url.path) {
        url
      } else {
        location.url?.appending(component: path)
      }
      
    case .keychain: nil
    case .memory: nil
    }
  }
  
  public var oldFileURL: URL? {
    switch location {
    case .defaults: nil
    case .file(let location, let path):
      location.url?.appending(component: path)
    case .keychain: nil
    case .memory: nil
    }
  }
//  public func migrate(from oldValue: OldProperty.Value) -> Value? { nil }
}
