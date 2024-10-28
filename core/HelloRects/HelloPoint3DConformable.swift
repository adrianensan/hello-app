import Foundation

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

public extension HelloPoint3D {
  static func +(left: Self, right: Self) -> Self {
    Self(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
  }
  
  static func -(left: Self, right: Self) -> Self {
    Self(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
  }
  
  static func +=(left: inout Self, right: Self) {
    left = left + right
  }
  
  static func -=(left: inout Self, right: Self) {
    left = left - right
  }
}

public extension HelloPoint3DConformable where NumberType: FloatingPoint {
  var magnitude: NumberType { sqrt(x * x + y * y + z * z) }
}

public extension HelloPoint3DConformable where NumberType: BinaryFloatingPoint {
  var simdFloat: SIMD3<Float> {
    SIMD3(x: Float(x), y: Float(y), z: Float(z))
  }
}
