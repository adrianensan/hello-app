import Foundation

public enum DefaultsPersistenceSuite: Hashable, Sendable {
  case standard
  case appGroup
  case hello
  case custom(String)
  
  public var id: String {
    switch self {
    case .standard: "standard"
    case .appGroup: "appGroup"
    case .hello: "hello"
    case .custom(let suite): suite
    }
  }
  
  public static var allCases: [DefaultsPersistenceSuite] { [
    .standard,
    .appGroup,
    .hello,
  ]}
  
  public var userDefaults: UserDefaults? {
    switch self {
    case .standard:
      return .standard
    case .appGroup:
      if let appGroupDefaults = UserDefaults(suiteName: AppInfo.appGroup) {
        return  appGroupDefaults
      } else {
        Log.fatal("Failed to create UserDefaults for app group, please ensure \(AppInfo.appGroup) is added as an App Group", context: "Persistence")
        return nil
      }
    case .hello:
      if let helloDefaults = UserDefaults(suiteName: "com.adrianensan.hello") {
        return  helloDefaults
      } else {
        Log.fatal("Failed to create UserDefaults for share Hello, please ensure com.adrianensan.hello is added as an App Group", context: "Persistence")
        return nil
      }
    case .custom(let suiteName):
      if let helloDefaults = UserDefaults(suiteName: suiteName) {
        return  helloDefaults
      } else {
        Log.fatal("Failed to create UserDefaults for \(suiteName)", context: "Persistence")
        return nil
      }
    }
  }
}

public enum FilePersistenceLocation: Hashable, Sendable {
  case decoument
  case applicationSupport
  case appGroup
  case temporary
  case cache
  case custom(String)
  
  public static var allCases: [FilePersistenceLocation] { [
    .decoument,
    .applicationSupport,
    .appGroup,
    .temporary,
    .cache
  ]}
  
  public var id: String {
    switch self {
    case .decoument: "document"
    case .applicationSupport: "support"
    case .appGroup: "appgroup"
    case .temporary: "temporary"
    case .cache: "cache"
    case .custom(let url): url
    }
  }
  
  public var url: URL? {
    switch self {
    case .decoument:
      .documentsDirectory.appending(component: AppInfo.bundleID, directoryHint: .isDirectory)
    case .applicationSupport:
      .applicationSupportDirectory.appending(component: AppInfo.bundleID, directoryHint: .isDirectory)
    case .appGroup:
      FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppInfo.appGroup)
    case .temporary:
      .temporaryDirectory.appending(component: AppInfo.bundleID, directoryHint: .isDirectory)
    case .cache:
      .cachesDirectory.appending(component: AppInfo.bundleID, directoryHint: .isDirectory)
    case .custom(let url):
      URL(string: url)?.appending(component: AppInfo.bundleID, directoryHint: .isDirectory)
    }
  }
}

public enum PersistenceType: Sendable {
  
  case defaults(suite: DefaultsPersistenceSuite = .standard, key: String)
  case file(location: FilePersistenceLocation = .decoument, path: String)
  case keychain(key: String)
  case memory(key: String)
  
  public var id: String {
    switch self {
    case .defaults(let suite, let key): "defaults-\(suite.id)-\(key)"
    case .file(let location, let path): "file-\(location.id)-\(path)"
    case .keychain(let key): "keychain-\(key)"
    case .memory(let key): "memory-\(key)"
    }
  }
}

public struct NoOld: PersistenceProperty {
  
  public var defaultValue: Bool? { nil }
  
  public var location: PersistenceType { .defaults(key: "nil") }
  
  public init() {}
}

public protocol PersistenceProperty: Sendable {
  
  associatedtype Value: Codable & Sendable
//  associatedtype Key: PersistenceKey
  associatedtype OldProperty: PersistenceProperty = NoOld
  
  static var persistence: HelloPersistence { get }
  
  var defaultValue: Value { get }
  
  var location: PersistenceType { get }
  
//  var key: Key { get }
  
  var isDeprecated: Bool { get }
  
  var allowCache: Bool { get }
  
  func cleanup(value: Value) -> Value
  
  var oldProperty: OldProperty? { get }
  
  func migrate(from oldValue: OldProperty.Value) -> Value?
}

extension PersistenceProperty {
  
  public static var persistence: HelloPersistence { Persistence.defaultPersistence }
  
  public func cleanup(value: Value) -> Value { value }
  
  public var allowCache: Bool {
    switch location {
    case .defaults: true
    case .file: false
    case .keychain: true
    case .memory: true
    }
  }
  public var isDeprecated: Bool { false }
  var id: String { location.id }
  
  public var oldProperty: OldProperty? { nil }
  public func migrate(from oldValue: OldProperty.Value) -> Value? { nil }
  
  public var fileURL: URL? {
    switch location {
    case .defaults: nil
    case .file(let location, let path): location.url?.appending(component: path)
    case .keychain: nil
    case .memory: nil
    }
  }
//  public func migrate(from oldValue: OldProperty.Value) -> Value? { nil }
}

@Observable
class PersistentObservable<Property: PersistenceProperty> {

  private let property: Property
  private var pendingChanges: Int = 0
  var internalValue: Property.Value
  
  var value: Property.Value {
    get { internalValue }
    set {
      internalValue = newValue
      Task { await Property.persistence.save(internalValue, for: property) }
    }
  }
  
  init(_ property: Property) {
    self.property = property
    internalValue = Property.persistence.storedValue(for: property)
  }
}

@propertyWrapper
@Observable
public class Persistent<Property: PersistenceProperty> {
  
  private let persistenObservable: PersistentObservable<Property>
  
  public var onUpdate: (() -> Void)? {
    didSet {
      if let onUpdate {
        trackNextChange()
      }
    }
  }
  
  private func trackNextChange() {
    withObservationTracking {
      let _ = persistenObservable.value
    } onChange: {
      Task { await self.valueChanged() }
    }
  }
  
  private func valueChanged() {
    guard let onUpdate else { return }
    onUpdate()
    trackNextChange()
  }
  
  public init(_ property: Property) {
    persistenObservable = Persistence.model(for: property)
  }
  
  public var wrappedValue: Property.Value {
    get { persistenObservable.value }
    set { persistenObservable.value = newValue }
  }
}
