import Foundation
import Observation

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


extension Never: PersistenceProperty {
  
  public var defaultValue: Never { fatalError("") }
  
  public var location: PersistenceType { .memory(key: "never") }
}

public protocol PersistenceProperty: Sendable {
  
  associatedtype Value: Codable & Sendable
//  associatedtype Key: PersistenceKey
  associatedtype OldProperty: PersistenceProperty = Never
  
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
  var value: Property.Value
  
  @MainActor
  func updateValue(to newValue: Property.Value) async {
    value = newValue
    await Property.persistence.save(value, for: property, skipModelUpdate: true)
  }
  
  init(_ property: Property) {
    self.property = property
    value = Property.persistence.storedValue(for: property)
  }
}

@propertyWrapper
@Observable
public class Persistent<Property: PersistenceProperty> {
  
  private let persistenObservable: PersistentObservable<Property>
  
  private var value: Property.Value
  
  public var onUpdate: (() -> Void)?
  
  private func trackNextChange() {
    withObservationTracking {
      let _ = persistenObservable.value
    } onChange: { [weak self] in
      guard let self else { return }
      valueChanged()
    }
  }
  
  private func valueChanged() {
    Task {
      value = persistenObservable.value
      trackNextChange()
      onUpdate?()
    }
  }
  
  public init(_ property: Property) {
    persistenObservable = Persistence.model(for: property)
    value = persistenObservable.value
    trackNextChange()
  }
  
  public var wrappedValue: Property.Value {
    get { value }
    set {
      value = newValue
      Task { await persistenObservable.updateValue(to: value) }
    }
  }
}
