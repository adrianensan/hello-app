import Foundation

public struct IsDeveloperPersistenceProperty: PersistenceProperty {
  
  public static var persistence: HelloPersistence { Persistence.defaultPersistence }
  
  public var defaultValue: Bool { false }
  
  public var location: PersistenceType { .defaults(key: "isDeveloper") }
}

public extension PersistenceProperty where Self == IsDeveloperPersistenceProperty {
  static var isDeveloper: IsDeveloperPersistenceProperty {
    IsDeveloperPersistenceProperty()
  }
}
