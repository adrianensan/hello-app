import Foundation

public struct UseBarelyVisibleThemeWhenDarkPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Bool { false }
  
  public var location: PersistenceType { .defaults(key: "use-barely-visible-theme-when-dark") }
}

public extension PersistenceProperty where Self == UseBarelyVisibleThemeWhenDarkPersistenceProperty {
  static var useBarelyVisibleThemeWhenDark: UseBarelyVisibleThemeWhenDarkPersistenceProperty {
    UseBarelyVisibleThemeWhenDarkPersistenceProperty()
  }
}
