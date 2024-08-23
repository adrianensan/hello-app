import Foundation

public struct LastDateLaunchedPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Date { .distantPast }
  
  public var location: PersistenceType { .defaults(key: "lastest-date-launched") }
}

public extension PersistenceProperty where Self == LastDateLaunchedPersistenceProperty {
  static var lastestDateLaunched: LastDateLaunchedPersistenceProperty {
    LastDateLaunchedPersistenceProperty()
  }
}
