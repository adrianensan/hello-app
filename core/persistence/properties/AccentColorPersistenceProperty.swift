import Foundation

public struct AccentColorPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: HelloColor { .retroApple.blue }
  
  public var location: PersistenceType { .defaults(suite: .appGroup, key: "accent-color") }
}

public extension PersistenceProperty where Self == AccentColorPersistenceProperty {
  static var accentColor: AccentColorPersistenceProperty {
    AccentColorPersistenceProperty()
  }
}
