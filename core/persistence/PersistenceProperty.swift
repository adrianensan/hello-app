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
        Log.fatal("Failed to create UserDefaults for app group, please ensure \(AppInfo.appGroup) is added as an App Group", context: "Persistence")
        return nil
      }
    case .helloShared:
      if let helloDefaults = UserDefaults(suiteName: AppInfo.helloGroup) {
        return helloDefaults
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

public enum FilePersistenceLocation: Hashable, Identifiable, Sendable {
  case document
  case applicationSupport
  case appGroup
  case helloShared
  case temporary
  case cache
  case custom(String)
  
  public static var allCases: [FilePersistenceLocation] { [
    .document,
    .applicationSupport,
    .appGroup,
    .helloShared,
    .temporary,
    .cache
  ]}
  
  public var id: String {
    switch self {
    case .document: "document"
    case .applicationSupport: "support"
    case .appGroup: "app-group"
    case .helloShared: "hello-shared"
    case .temporary: "temporary"
    case .cache: "cache"
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
      FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppInfo.helloGroup)
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
  var defaultDemoValue: Value { get }
  
  var allowedInDemoMode: Bool { get }
  
  var location: PersistenceType { get }
  
//  var key: Key { get }
  
  var isDeprecated: Bool { get }
  
  var allowCache: Bool { get }
  
  var persistDefaultValue: Bool { get }
  
  func cleanup(value: Value) -> Value
  
  var oldProperty: OldProperty? { get }
  
  func migrate(from oldValue: OldProperty.Value) -> Value?
}

extension PersistenceProperty {
  
  public static var persistence: HelloPersistence { Persistence.defaultPersistence }
  
  public func cleanup(value: Value) -> Value { value }
  
  public var defaultDemoValue: Value { defaultValue }
  
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

//@Observable
//class PersistentObservable<Property: PersistenceProperty> {
//
//  private let property: Property
//  var value: Property.Value
//  
//  @MainActor
//  func updateValue(to newValue: Property.Value) async {
//    value = newValue
//    await Property.persistence.save(value, for: property, skipModelUpdate: true)
//  }
//  
//  init(_ property: Property) {
//    self.property = property
//    value = Property.persistence.storedValue(for: property)
//  }
//}
//
//@propertyWrapper
//@Observable
//public class Persistent<Property: PersistenceProperty> {
//  
//  private let persistenObservable: PersistentObservable<Property>
//  
//  private var value: Property.Value
//  
//  public var onUpdate: (() -> Void)?
//  
//  private func trackNextChange() {
//    withObservationTracking {
//      let _ = persistenObservable.value
//    } onChange: { [weak self] in
//      guard let self else { return }
//      valueChanged()
//    }
//  }
//  
//  private func valueChanged() {
//    Task {
//      try? await Task.sleep(seconds: 0.02)
//      value = persistenObservable.value
//      trackNextChange()
//      onUpdate?()
//    }
//  }
//  
//  public init(_ property: Property) {
//    persistenObservable = Persistence.model(for: property)
//    value = persistenObservable.value
//    trackNextChange()
//  }
//  
//  public var wrappedValue: Property.Value {
//    get { value }
//    set {
//      value = newValue
//      Task { await persistenObservable.updateValue(to: value) }
//    }
//  }
//}

@MainActor
@Observable
public class PersistentObservable<Property: PersistenceProperty> {

  private let property: Property
  public internal(set) var _value: Property.Value
  public var value: Property.Value {
    get { _value }
    set {
      _value = newValue
      Task { await Property.persistence.save(value, for: property, skipModelUpdate: true) }
    }
  }
//  {
//    didSet { notifyListeners() }
//  }

//  @ObservationIgnored private var listeners: [Weak<PersistentAsync<Property>>] = []
//  @ObservationIgnored private var listenerToSkip: PersistentAsync<Property>?

  init(_ property: Property) {
    self.property = property
    _value = Property.persistence.storedValue(for: property)
  }
  
//  func updateValue(to newValue: Property.Value, from listener: PersistentAsync<Property>? = nil) {
  func updateValue(to newValue: Property.Value) {
//    listenerToSkip = listener
    _value = newValue
//    listenerToSkip = nil
    Task { await Property.persistence.save(value, for: property, skipModelUpdate: true) }
  }

//  @MainActor
//  func listen(_ listener: PersistentAsync<Property>) {
//    listeners.append(Weak(value: listener))
//  }

//  private func notifyListeners() {
//    for (i, weakListener) in listeners.enumerated().reversed() {
//      if let listener = weakListener.value {
//        if listener !== listenerToSkip {
//          listener.valueUpdated()
//        }
//      } else {
//        listeners.remove(at: i)
//      }
//    }
//  }
}

//@propertyWrapper
//public struct PersistentNew<Property: PersistenceProperty> {
//  
//  private let persistenObservable: PersistentObservable<Property>
//  
//  private var value: Property.Value
//  
//  public init(_ property: Property) {
//    persistenObservable = Persistence.model(for: property)
//    value = persistenObservable.value
////    Task { await persistenObservable.listen(self) }
//  }
//  
//  fileprivate mutating func valueUpdated() {
//    value = persistenObservable.value
//  }
//  
//  public var wrappedValue: Property.Value {
//    get { value }
//    mutating set {
//      value = newValue
//      valueUpdated()
////      Task { await persistenObservable.updateValue(to: value, from: self) }
//    }
//  }
//}

//@propertyWrapper
//@Observable
//public final class PersistentAsync<Property: PersistenceProperty>: Sendable {
//
//  private let persistenObservable: PersistentObservable<Property>
//
//  private var value: Property.Value
//
//  public var onUpdate: (() -> Void)?
//
//  public init(_ property: Property) {
//    persistenObservable = Persistence.model(for: property)
//    value = persistenObservable.value
//    Task { await persistenObservable.listen(self) }
//  }
//  
//  fileprivate func valueUpdated() {
//    value = persistenObservable.value
//    onUpdate?()
//  }
//
//  public var wrappedValue: Property.Value {
//    get { value }
//    set {
//      value = newValue
//      Task { await persistenObservable.updateValue(to: value, from: self) }
//    }
//  }
//}

//public final class PersistentAsync<Property: PersistenceProperty>: Sendable {
//  
//  private let property: Property
//  
//  public init(_ property: Property) {
//    self.property = property
//  }
//  
//  public var value: Property.Value { get async { await Persistence.model(for: property).value } }
//  
//  public func update(to newValue: Property.Value) async {
//    await Persistence.model(for: property).updateValue(to: newValue)
//  }
//  
//  public func onChange(_: @escaping (Property.Value) -> Void) async {
//    await Persistence.model(for: property).listen(self)
//  }
//  
//  fileprivate func valueUpdated() {
//    //    value = persistenObservable.value
//    //    onUpdate?()
//    //  }
//  }
//}

@MainActor
@propertyWrapper
public struct Persistent<Property: PersistenceProperty> {
  
  private let persistenObservable: PersistentObservable<Property>
  
  public init(_ property: Property) {
    persistenObservable = Persistence.model(for: property)
  }
  
  public var wrappedValue: Property.Value {
    get { persistenObservable.value }
    nonmutating set { persistenObservable.updateValue(to: newValue) }
  }
}
