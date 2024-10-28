import Foundation

public struct MaskToDeviceShapePersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Bool { false }
  
  public var location: PersistenceType { .defaults(key: "mask-to-device-hape") }
}

public extension PersistenceProperty where Self == MaskToDeviceShapePersistenceProperty {
  static var maskToDeviceShape: MaskToDeviceShapePersistenceProperty {
    MaskToDeviceShapePersistenceProperty()
  }
}
