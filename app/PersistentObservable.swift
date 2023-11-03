//#if canImport(Observation)
//import Observation
//import SwiftUI
//
//import HelloCore
//
//@available(iOS 17, macOS 14, watchOS 10, *)
//@MainActor @Observable
//@propertyWrapper
//public class Persistent2<Property: PersistenceProperty> {
//  
//  private let persistence: OFPersistence
//  private let property: Property
//  private var value: Property.Value
//  
//  public var onUpdate: (() -> Void)?
//  
//  public init(_ property: Property, in persistence: OFPersistence = Property.persistence) {
//    self.persistence = persistence
//    self.property = property
//    value = persistence.initialValue(for: property)
//    Task { [weak self] in
//      for try await update in await persistence.updates(for: property) {
//        try Task.checkCancellation()
//        guard let self else { return }
//        self.value = update
//        self.onUpdate?()
//      }
//    }
//  }
//  
//  public var wrappedValue: Property.Value {
//    get { value }
//    set {
//      value = newValue
//      Task {
//        await persistence.save(value, for: property)
//      }
//    }
//  }
//}
//
//@available(iOS 17, macOS 14, watchOS 10, *)
//@MainActor
//@propertyWrapper
//public struct PersistentObservable<Property: PersistenceProperty>: DynamicProperty {
//  
//  @State private var persistentInternal: Persistent2<Property>
//  
//  public init(_ property: Property, in persistence: OFPersistence = Property.persistence) {
//    _persistentInternal = .init(initialValue: Persistent2(property, in: persistence))
//  }
//  
//  public var wrappedValue: Property.Value {
//    get { persistentInternal.wrappedValue }
//    nonmutating set { persistentInternal.wrappedValue = newValue }
//  }
//}
//#endif
