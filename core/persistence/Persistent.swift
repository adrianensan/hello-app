import Foundation
import Observation

@MainActor
@Observable
public class PersistentObservable<Property: PersistenceProperty> {
  
  private let property: Property
  public internal(set) var _value: Property.Value
  public var value: Property.Value {
    get { _value }
    set {
      _value = newValue
      Task { await HelloEnvironment.object(for: .persistence).save(value, for: property, skipModelUpdate: true) }
    }
  }
  
  init(_ property: Property) {
    self.property = property
    _value = HelloEnvironment.object(for: .persistence).storedValue(for: property)
  }
  
  func updateValue(to newValue: Property.Value) {
    _value = newValue
    Task { await HelloEnvironment.object(for: .persistence).save(value, for: property, skipModelUpdate: true) }
  }
}

/// A property wrapper type that reflects a persistent value.
/// This property also triggers a view update in SwiftUI views when it changes
///
/// Updatating this property instantly updates all other instances of this property wrapper,
/// and asyncronously updates the underlying stored value
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
