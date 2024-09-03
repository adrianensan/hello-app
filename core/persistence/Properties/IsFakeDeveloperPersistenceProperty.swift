import Foundation

public struct IsFakeDeveloperPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Bool { false }
  
  public func defaultValue(for mode: PersistenceMode) -> Bool {
    switch mode {
    case .normal: false
    case .demo: true
    case .freshInstall: true
    }
  }
  
  public var location: PersistenceType { .defaults(key: "is-fake-developer") }
}

public extension PersistenceProperty where Self == IsFakeDeveloperPersistenceProperty {
  static var isFakeDeveloper: IsFakeDeveloperPersistenceProperty {
    IsFakeDeveloperPersistenceProperty()
  }
}
