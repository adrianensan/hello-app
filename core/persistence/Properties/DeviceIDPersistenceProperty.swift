import Foundation

public struct DeviceIDPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: String { UUID().uuidString }
  
  public var location: PersistenceType { .defaults(key: "deviceID") }
}

public extension PersistenceProperty where Self == DeviceIDPersistenceProperty {
  static var deviceID: DeviceIDPersistenceProperty {
    DeviceIDPersistenceProperty()
  }
}
