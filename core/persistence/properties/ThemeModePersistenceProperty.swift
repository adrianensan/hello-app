import Foundation

public enum ThemeMode: String, Identifiable, Codable, CaseIterable, Sendable {
  case auto
  case alwaysLight
  case alwaysDark
  
  public var id: String { rawValue }
  
  public var name: String {
    switch self {
    case .auto: "Auto"
    case .alwaysLight: "Always Light"
    case .alwaysDark: "Always Dark"
    }
  }
  
  public func effectiveScheme(for colorScheme: HelloThemeScheme) -> HelloThemeScheme {
    switch self {
    case .auto: colorScheme
    case .alwaysLight: .light
    case .alwaysDark: .dark
    }
  }
}

public struct ThemeModePersistenceProperty: PersistenceProperty {
  
  public var defaultValue: ThemeMode { .auto }
  
  public var location: PersistenceType { .defaults(suite: .appGroup, key: "theme-mode") }
}

public extension PersistenceProperty where Self == ThemeModePersistenceProperty {
  static var themeMode: ThemeModePersistenceProperty {
    ThemeModePersistenceProperty()
  }
}
