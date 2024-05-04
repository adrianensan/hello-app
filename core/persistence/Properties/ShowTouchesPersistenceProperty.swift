import Foundation

public struct ShowTouchesPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Bool { false }
  
  public var location: PersistenceType { .defaults(key: "show-touches") }
}

public extension PersistenceProperty where Self == ShowTouchesPersistenceProperty {
  static var showTouches: ShowTouchesPersistenceProperty {
    ShowTouchesPersistenceProperty()
  }
}
