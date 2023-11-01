import Foundation

public struct IsTesterPersistenceProperty: PersistenceProperty {
  
  public static var persistence: OFPersistence { Persistence.defaultPersistence }
  
  public var defaultValue: Bool { false }
  
  public var location: PersistenceType { .defaults(key: "isTester") }
}

public extension PersistenceProperty where Self == IsTesterPersistenceProperty {
  static var isTester: IsTesterPersistenceProperty {
    IsTesterPersistenceProperty()
  }
}
