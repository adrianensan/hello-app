import Foundation

public struct DeviceIDPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Bool { false }
  
  public var location: PersistenceType { .defaults(key: "deviceID") }
}

public extension PersistenceProperty where Self == DeviceIDPersistenceProperty {
  static var deviceID: DeviceIDPersistenceProperty {
    DeviceIDPersistenceProperty()
  }
}
