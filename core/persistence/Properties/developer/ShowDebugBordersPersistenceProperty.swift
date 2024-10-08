import Foundation

public struct ShowDebugBordersPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Bool { false }
  
  public var location: PersistenceType { .defaults(key: "show-debug-borders") }
}

public extension PersistenceProperty where Self == ShowDebugBordersPersistenceProperty {
  static var showDebugBorders: ShowDebugBordersPersistenceProperty {
    ShowDebugBordersPersistenceProperty()
  }
}
