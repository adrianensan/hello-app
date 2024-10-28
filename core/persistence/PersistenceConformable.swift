import Foundation

@globalActor final public actor HelloPersistenceActor: GlobalActor {
  public static let shared: HelloPersistenceActor = HelloPersistenceActor()
}

public struct PersistenceHelloEnvironmentKey: HelloEnvironmentObjectKey {
  public static let defaultValue: any HelloPersistenceConformable = HelloPersistence()
}

public extension HelloEnvironmentObjectKey where Self == PersistenceHelloEnvironmentKey {
  static var persistence: PersistenceHelloEnvironmentKey { PersistenceHelloEnvironmentKey() }
}

@HelloPersistenceActor
public protocol HelloPersistenceConformable: Sendable {
  
  nonisolated var keychain: KeychainHelper { get }
  
  func listen<Property: PersistenceProperty>(for property: Property,
                                             object: AnyObject,
                                             action: @escaping @Sendable (Property.Value) async -> Void,
                                             initial: Bool) async
  
  nonisolated func saveInternal<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) throws
  
  func save<Property: PersistenceProperty>(_ value: Property.Value, for property: Property, skipModelUpdate: Bool)
  
  nonisolated func storedValue<Property: PersistenceProperty>(for property: Property) -> Property.Value
  
  func value<Property: PersistenceProperty>(for property: Property) -> Property.Value
  
  func atomicUpdate<Property: PersistenceProperty>(_ property: Property, update: (Property.Value) -> Property.Value)
  
  func delete<Property: PersistenceProperty>(property: Property)
  
  func nuke()
  
  nonisolated func size<Property: PersistenceProperty>(of property: Property) -> Int
  
  func isSet<Property: PersistenceProperty>(property: Property) -> Bool
  
  nonisolated func unsafeIsSet<Property: PersistenceProperty>(property: Property) -> Bool
  
  nonisolated func fileURL<Property: PersistenceProperty>(for property: Property) -> URL?
  
  nonisolated func rootURL<Property: PersistenceProperty>(for property: Property) -> URL?
}

public extension HelloPersistenceConformable {
  func listen<Property: PersistenceProperty>(for property: Property,
                                             object: AnyObject,
                                             action: @escaping @Sendable (Property.Value) async -> Void) async {
    await listen(for: property, object: object, action: action, initial: false)
  }
  
  func save<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) {
    save(value, for: property, skipModelUpdate: false)
  }
}
