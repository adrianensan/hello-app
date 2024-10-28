import Foundation

public struct ActiveAppIconPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: String? { nil }
  
  public var location: PersistenceType { .defaults(suite: .appGroup, key: "app-icon") }
}

public extension PersistenceProperty where Self == ActiveAppIconPersistenceProperty {
  static var activeAppIcon: ActiveAppIconPersistenceProperty {
    ActiveAppIconPersistenceProperty()
  }
}
