import Foundation

public struct LastestVersionLaunchedPersistentProperty: PersistenceProperty {
  
  public static var persistence: HelloPersistence { Persistence.defaultPersistence }
  
  public var defaultValue: AppVersion? { nil }
  
  public var location: PersistenceType { .defaults(key: "lastestVersionLaunched") }
}

public extension PersistenceProperty where Self == LastestVersionLaunchedPersistentProperty {
  static var lastestVersionLaunched: LastestVersionLaunchedPersistentProperty {
    LastestVersionLaunchedPersistentProperty()
  }
}
