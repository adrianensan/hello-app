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
  
  public static var persistence: OFPersistence {
    OFPersistence(defaultsSuiteName: nil, pathRoot: URL(string: "")!, keychain: .init(service: ""))
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
  
  static var persistence: OFPersistence { get }
  
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
  
  public static var persistence: OFPersistence { Persistence.defaultPersistence }
  
  public func cleanup(value: Value) -> Value { value }
  
  public var allowCache: Bool { true }
  public var isDeprecated: Bool { false }
  
  public var oldProperty: OldProperty? { nil }
  public func migrate(from oldValue: OldProperty.Value) -> Value? { nil }
//  public func migrate(from oldValue: OldProperty.Value) -> Value? { nil }
}

@propertyWrapper
public class Persistent<Property: PersistenceProperty> {
  
  private let persistence: OFPersistence
  private let property: Property
  private var value: Property.Value
  
  public var onUpdate: (() -> Void)?
  
  public init(_ property: Property, in persistence: OFPersistence = Property.persistence) {
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
