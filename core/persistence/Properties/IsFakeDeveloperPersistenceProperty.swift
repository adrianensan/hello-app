import Foundation

public struct IsFakeDeveloperPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Bool { false }
  
  public var defaultDemoValue: Bool { true }
  
  public var location: PersistenceType { .defaults(key: "is-fake-developer") }
}

public extension PersistenceProperty where Self == IsFakeDeveloperPersistenceProperty {
  static var isFakeDeveloper: IsFakeDeveloperPersistenceProperty {
    IsFakeDeveloperPersistenceProperty()
  }
}
