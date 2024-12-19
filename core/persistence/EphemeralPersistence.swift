import Foundation

@HelloPersistenceActor
public class EphemeralPersistence: HelloPersistenceConformable {
  
  public struct Listener<Property: PersistenceProperty> {
    weak var object: AnyObject?
    var callback: @Sendable (Property.Value) async -> Void
    
    init(object: AnyObject, callback: @escaping @Sendable (Property.Value) async -> Void) {
      self.object = object
      self.callback = callback
    }
  }
  
  private var cache: [String: Any] = [:]
  private var listeners: [String: [Any]] = [:]
  
  nonisolated public let mode: PersistenceMode = (try? UserDefaults.standard.value(for: .persistenceMode)) ?? .normal
  nonisolated public let keychain = KeychainHelper(service: AppInfo.bundleID, group: AppInfo.appGroup)
  
  nonisolated init() {}
  
  public func listen<Property: PersistenceProperty>(for property: Property,
                                             object: AnyObject,
                                             action: @escaping @Sendable (Property.Value) async -> Void,
                                             initial: Bool) async {
    
  }
  
  nonisolated public func saveInternal<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) throws { }
  
  public func save<Property: PersistenceProperty>(_ value: Property.Value, for property: Property, skipModelUpdate: Bool) {
    cache[property.id] = value
  }
  
  nonisolated public func storedValue<Property: PersistenceProperty>(for property: Property) -> Property.Value {
    property.defaultValue(for: mode)
  }
  
  public func value<Property: PersistenceProperty>(for property: Property) -> Property.Value {
    (cache[property.id] as? Property.Value) ?? property.defaultValue(for: mode)
  }
  
  public func atomicUpdate<Property: PersistenceProperty>(_ property: Property, update: (Property.Value) -> Property.Value) {
    cache[property.id] = update(value(for: property))
  }
  
  public func delete<Property: PersistenceProperty>(property: Property) {
    cache[property.id] = nil
  }
  
  public func nuke() {
    cache = [:]
  }
  
  nonisolated public func size<Property: PersistenceProperty>(of property: Property) -> Int { 0 }
  
  public func isSet<Property: PersistenceProperty>(property: Property) -> Bool { cache[property.id] != nil }
  
  nonisolated public func unsafeIsSet<Property: PersistenceProperty>(property: Property) -> Bool { false }
  
  nonisolated public func fileURL<Property: PersistenceProperty>(for property: Property) -> URL? { nil }
  
  nonisolated public func rootURL<Property: PersistenceProperty>(for property: Property) -> URL? { nil }
}
