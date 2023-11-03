//import SwiftUI
//import Observation
//
//import HelloCore
//
//@MainActor
//@Observable
//fileprivate class PersistentStateInternal<Property: PersistenceProperty> {
//  
//  private let persistence: OFPersistence
//  private let property: Property
//  private var updateTask: Task<Void, any Error>?
//  
//  var value: Property.Value
//  
//  init(persistence: OFPersistence, property: Property) {
//    self.persistence = persistence
//    self.property = property
//    self.value = persistence.initialValue(for: property)
//    updateTask = Task { [weak self] in
//      for try await update in await persistence.updates(for: property) {
//        try Task.checkCancellation()
//        guard let self else { return }
//        self.value = update
//      }
//    }
//  }
//  
//  public func update(to newValue: Property.Value) {
//    value = newValue
//    Task {
//      await persistence.save(value, for: property)
//    }
//  }
//}
//
//@MainActor
//@propertyWrapper
//public struct PersistentState<Property: PersistenceProperty>: DynamicProperty {
//  
//  @State private var persistentInternal: PersistentStateInternal<Property>
//  
//  public init(_ property: Property, in persistence: OFPersistence = Property.persistence) {
//    _persistentInternal = State(initialValue: PersistentStateInternal(persistence: persistence, property: property))
//  }
//  
//  public var wrappedValue: Property.Value {
//    get { persistentInternal.value }
//    nonmutating set { persistentInternal.update(to: newValue) }
//  }
//}
