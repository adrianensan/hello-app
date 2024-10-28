import Foundation

public struct IsTesterPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Bool { false }
  
  public var location: PersistenceType { .defaults(key: "is-tester") }
}

public extension PersistenceProperty where Self == IsTesterPersistenceProperty {
  static var isTester: IsTesterPersistenceProperty {
    IsTesterPersistenceProperty()
  }
}
