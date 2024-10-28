import Foundation

public struct IsDeveloperPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Bool { false }
  
  public var location: PersistenceType { .defaults(key: "is-developer") }
}

public extension PersistenceProperty where Self == IsDeveloperPersistenceProperty {
  static var isDeveloper: IsDeveloperPersistenceProperty {
    IsDeveloperPersistenceProperty()
  }
}
