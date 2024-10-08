import Foundation

public struct DisableMaskingPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Bool { false }
  
  public func defaultValue(for mode: PersistenceMode) -> Bool {
    switch mode {
    case .normal: false
    case .demo: true
    case .freshInstall: false
    }
  }
  
  public var location: PersistenceType { .defaults(key: "disable-masking") }
}

public extension PersistenceProperty where Self == DisableMaskingPersistenceProperty {
  static var disableMasking: DisableMaskingPersistenceProperty {
    DisableMaskingPersistenceProperty()
  }
}
