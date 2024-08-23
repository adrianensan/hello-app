import Foundation

public struct LastestVersionLaunchedPersistentProperty: PersistenceProperty {
  
  public var defaultValue: AppVersion? { nil }
  
  public var location: PersistenceType { .defaults(key: "lastest-version-launched") }
}

public extension PersistenceProperty where Self == LastestVersionLaunchedPersistentProperty {
  static var lastestVersionLaunched: LastestVersionLaunchedPersistentProperty {
    LastestVersionLaunchedPersistentProperty()
  }
}
