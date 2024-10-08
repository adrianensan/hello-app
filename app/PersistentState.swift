//import SwiftUI
//
//import HelloCore
//
//@MainActor
//fileprivate class PersistentStateInternal<Property: PersistenceProperty>: ObservableObject {
//  
//  private let persistence: HelloPersistence
//  private let property: Property
//  private var updateTask: Task<Void, any Error>?
//  
//  @Published var value: Property.Value
//  
//  init(persistence: HelloPersistence, property: Property) {
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
//  @StateObject private var persistentInternal: PersistentStateInternal<Property>
//  
//  public init(_ property: Property, in persistence: HelloPersistence = Property.persistence) {
//    _persistentInternal = StateObject(wrappedValue: PersistentStateInternal(persistence: persistence, property: property))
//  }
//  
//  public var wrappedValue: Property.Value {
//    get { persistentInternal.value }
//    nonmutating set { persistentInternal.update(to: newValue) }
//  }
//}
