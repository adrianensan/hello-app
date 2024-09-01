import Foundation

public struct IsDemoModePersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Bool { false }
  
  public var defaultDemoValue: Bool { true }
  
  public var location: PersistenceType { .defaults(key: "is-demo-mode") }
}

public extension PersistenceProperty where Self == IsDemoModePersistenceProperty {
  static var isDemoMode: IsDemoModePersistenceProperty {
    IsDemoModePersistenceProperty()
  }
}
