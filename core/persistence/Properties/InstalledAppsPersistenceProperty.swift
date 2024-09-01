import Foundation

public struct InstalledAppsPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Set<String> { [] }
  
  public var location: PersistenceType { .file(location: .helloShared, path: "installed-apps.json") }
}

public extension PersistenceProperty where Self == InstalledAppsPersistenceProperty {
  static var installedApps: InstalledAppsPersistenceProperty {
    InstalledAppsPersistenceProperty()
  }
}
