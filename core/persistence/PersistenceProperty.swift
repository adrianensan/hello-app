import Foundation

extension Never: PersistenceProperty {
  
  public var defaultValue: Never { fatalError("") }
  
  public var location: PersistenceType { .memory(key: "never") }
}


public protocol DeprecatedPersistenceProperty: PersistenceProperty {
  
}

public extension DeprecatedPersistenceProperty {
  var isDeprecated: Bool { true }
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
