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
  
  public var description: String { "(\(x), \(y), \(z))" }
}

extension SIMD3<Float>: HelloPoint3DConformable {}

public func abs(_ point: SIMD3<Float>) -> SIMD3<Float> {
  SIMD3(x: abs(point.x), y: abs(point.y), z: abs(point.z))
}

public protocol HelloPoint3DConformable<NumberType> {
  
  associatedtype NumberType: HelloNumeric
  
  var x: NumberType { get set }
  var y: NumberType { get set }
  var z: NumberType { get set }
  
  init(x: NumberType, y: NumberType, z: NumberType)
}

public extension HelloPoint3DConformable where Self == SIMD3<NumberType> {
  var xy: SIMD2<NumberType> {
    SIMD2(x: x, y: y)
  }
}

public extension HelloPoint3DConformable {
  var xy: HelloPoint<NumberType> {
    HelloPoint(x: x, y: y)
  }
}

public extension HelloPoint3DConformable where NumberType: FloatingPoint {
  var magnitude: NumberType { sqrt(x * x + y * y + z * z) }
}

public extension HelloPoint3DConformable where NumberType: BinaryFloatingPoint {
  public var simdFloat: SIMD3<Float> {
    SIMD3(x: Float(x), y: Float(y), z: Float(z))
  }
}
