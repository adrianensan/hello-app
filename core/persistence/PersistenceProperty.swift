import Foundation

public enum PersistenceType: Sendable {
  case defaults(key: String)
  case file(path: String)
  case keychain(key: String)
  case memory
}

public struct NoOld<Key: PersistenceKey>: PersistenceProperty {
  
  public var key: Key
  
  public var defaultValue: Bool? { nil }
  
  public var location: PersistenceType { .defaults(key: "nil") }
  
  public typealias Value = Bool?
  
  public init(key: Key) {
    self.key = key
  }
  
}

public protocol PersistenceProperty: Sendable {
  
  associatedtype Value: Codable & Sendable
  associatedtype Key: PersistenceKey
  associatedtype OldProperty: PersistenceProperty = NoOld<Key>
  
  var defaultValue: Value { get }
  
  var location: PersistenceType { get }
  
  var key: Key { get }
  
  var isDeprecated: Bool { get }
  
  var allowCache: Bool { get }
  
  func cleanup(value: Value) -> Value
  
  var oldProperty: OldProperty? { get }
  
  func migrate(from oldValue: OldProperty.Value) -> Value?
}

extension PersistenceProperty {
  public func cleanup(value: Value) -> Value { value }
  
  public var allowCache: Bool { true }
  public var isDeprecated: Bool { false }
  
  public var oldProperty: OldProperty? { nil }
  public func migrate(from oldValue: OldProperty.Value) -> Value? { nil }
//  public func migrate(from oldValue: OldProperty.Value) -> Value? { nil }
}

@propertyWrapper
public class Persistent<Property: PersistenceProperty> {
  
  private let persistence: OFPersistence<Property.Key>
  private let property: Property
  private var value: Property.Value
  
  public var onUpdate: (() -> Void)?
  
  public init(_ property: Property, in persistence: OFPersistence<Property.Key> = Property.Key.persistence) {
    self.persistence = persistence
    self.property = property
    value = persistence.initialValue(for: property)
    Task { [weak self] in
      for try await update in await persistence.updates(for: property) {
        try Task.checkCancellation()
        guard let self else { return }
        self.value = update
        self.onUpdate?()
      }
    }
  }
  
  public var wrappedValue: Property.Value {
    get { value }
    set {
      value = newValue
      Task {
        await persistence.save(value, for: property)
      }
    }
  }
}
