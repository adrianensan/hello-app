import Foundation

public struct UnlockedAppIconsPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Set<String> { [] }
  
  public var location: PersistenceType { .file(location: .applicationSupport, path: "unlocked-app-icons.json") }
  
  public var allowCache: Bool { true }
}

public extension PersistenceProperty where Self == UnlockedAppIconsPersistenceProperty {
  static var unlockedAppIcons: UnlockedAppIconsPersistenceProperty {
    UnlockedAppIconsPersistenceProperty()
  }
}
