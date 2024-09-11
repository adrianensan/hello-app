import Foundation

public struct FirstDateLaunchedPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Date { .now }
  
  public var persistDefaultValue: Bool { true }
  
  public var location: PersistenceType { .defaults(key: "first-date-launched") }
}

public extension PersistenceProperty where Self == FirstDateLaunchedPersistenceProperty {
  static var firstDateLaunched: FirstDateLaunchedPersistenceProperty {
    FirstDateLaunchedPersistenceProperty()
  }
}
