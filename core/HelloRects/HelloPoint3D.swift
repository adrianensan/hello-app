import Foundation

public struct HelloPoint3D<NumberType: HelloNumeric>: HelloPoint3DConformable, Hashable, Codable, Sendable, CustomStringConvertible {
  
  public static var zero: Self { Self(x: 0, y: 0, z: 0) }
  public static var one: Self { Self(x: 1, y: 1, z: 1) }
  
  public var x: NumberType
  public var y: NumberType
  public var z: NumberType
  
  public init(x: NumberType, y: NumberType, z: NumberType) {
    self.x = x
    self.y = y
    self.z = z
  }
  
  public init(x: some BinaryInteger, y: some BinaryInteger, z: some BinaryInteger) {
    self.x = NumberType(x)
    self.y = NumberType(y)
    self.z = NumberType(z)
  }
  
  public init(x: some BinaryFloatingPoint, y: some BinaryFloatingPoint, z: some BinaryFloatingPoint) {
    self.x = NumberType(x)
    self.y = NumberType(y)
    self.z = NumberType(z)
  }
  
  public init(simd: SIMD3<Float>) {
    self.x = NumberType(simd.x)
    self.y = NumberType(simd.y)
    self.z = NumberType(simd.z)
  }
  
  public var description: String { "(\(x), \(y), \(z))" }
}
