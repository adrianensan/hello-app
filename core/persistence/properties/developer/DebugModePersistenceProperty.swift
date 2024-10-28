import Foundation

public struct ShowDebugModePersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Bool { false }
  
  public var location: PersistenceType { .defaults(key: "show-debug-content") }
}

public extension PersistenceProperty where Self == ShowDebugModePersistenceProperty {
  static var showDebugContent: ShowDebugModePersistenceProperty {
    ShowDebugModePersistenceProperty()
  }
}
