import Foundation

public struct PersistenceModePersistenceProperty: PersistenceProperty {
  
  public var defaultValue: PersistenceMode { .normal }
  
  public var allowedInDemoMode: Bool { true }
  
  public var location: PersistenceType { .defaults(key: "persistence-mode") }
}

public extension PersistenceProperty where Self == PersistenceModePersistenceProperty {
  static var persistenceMode: PersistenceModePersistenceProperty {
    PersistenceModePersistenceProperty()
  }
}
