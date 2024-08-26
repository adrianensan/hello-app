import Foundation

public struct DeviceIDPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: String { .uuid }
  
  public var location: PersistenceType { .defaults(suite: .helloShared, key: "device-id") }
  
  public var persistDefaultValue: Bool { true }
}

public extension PersistenceProperty where Self == DeviceIDPersistenceProperty {
  static var deviceID: DeviceIDPersistenceProperty {
    DeviceIDPersistenceProperty()
  }
}
