import SwiftUI

import HelloCore

@MainActor
fileprivate class PersistentInternal<Property: PersistenceProperty>: ObservableObject, PersistenceSubscriber {
  
  private let persistence: OFPersistence<Property.Key>
  private let property: Property
  
  @Published var value: Property.Value
  
  init(persistence: OFPersistence<Property.Key>, property: Property) {
    self.persistence = persistence
    self.property = property
    value = Persistence.value(property)
    persistence.subscribe(self, to: property.key)
  }
  
  public func update(to newValue: Property.Value) {
    persistence.save(newValue, for: property)
  }
  
  public func valueUpdated<Key: PersistenceKey>(for key: Key) {
    value = Persistence.value(property)
  }
}

@MainActor
@propertyWrapper
public struct Persistent<Property: PersistenceProperty>: DynamicProperty {
  
  @StateObject private var persistentInternal: PersistentInternal<Property>
  
  public init(_ property: Property, in persistence: OFPersistence<Property.Key> = Property.Key.persistence) {
    _persistentInternal = StateObject(wrappedValue: PersistentInternal(persistence: persistence, property: property))
  }
  
  public var wrappedValue: Property.Value {
    get { persistentInternal.value }
    nonmutating set { persistentInternal.update(to: newValue) }
  }
}
