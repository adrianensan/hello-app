import Foundation

public struct DeviceIDPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: String { .uuid }
  
  public func defaultValue(for mode: PersistenceMode) -> String {
    switch mode {
    case .normal: .uuid
    case .demo: "demo"
    case .freshInstall: "new"
    }
  }
  
  public var location: PersistenceType { .defaults(suite: .helloShared, key: "device-id") }
  
  public var persistDefaultValue: Bool { true }
}

public extension PersistenceProperty where Self == DeviceIDPersistenceProperty {
  static var deviceID: DeviceIDPersistenceProperty {
    DeviceIDPersistenceProperty()
  }
}
