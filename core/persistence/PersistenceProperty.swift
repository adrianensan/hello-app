import Foundation

public enum PersistenceType: Sendable {
  case defaults(key: String)
  case file(path: String)
  case keychain(key: String)
  case memory(key: String)
  
  public var id: String {
    switch self {
    case .defaults(let key): "defaults-\(key)"
    case .file(let path): "file-\(path)"
    case .keychain(let key): "keychain-\(key)"
    case .memory(let key): "memory-\(key)"
    }
  }
}

public struct NoOld: PersistenceProperty {
  
  public static var persistence: HelloPersistence {
    HelloPersistence(defaultsSuiteName: nil, pathRoot: URL(string: "")!, keychain: .init(service: ""))
  }
  
//  public var key: Key
  
  public var defaultValue: Bool? { nil }
  
  public var location: PersistenceType { .defaults(key: "nil") }
  
  public typealias Value = Bool?
  
  public init() {
//    self.key = key
  }
  
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
//  public func migrate(from oldValue: OldProperty.Value) -> Value? { nil }
}

@MainActor
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

@MainActor
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
