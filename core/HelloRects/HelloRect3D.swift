import Foundation

public typealias IntPoint3D = HelloPoint3D<Int>
public typealias IntSize3D = HelloSize3D<Int>
public typealias IntRect3D = HelloRect3D<Int>

public typealias FloatPoint3D = HelloPoint3D<Float>
public typealias FloatSize3D = HelloSize3D<Float>
public typealias FloatRect3D = HelloRect3D<Float>

public typealias DoublePoint3D = HelloPoint3D<Double>
public typealias DoubleSize3D = HelloSize3D<Double>
public typealias DoubleRect3D = HelloRect3D<Double>

//extension SIMD3<Float>: HelloPoint3DConformable {
//  public init(x: some BinaryFloatingPoint, y: some BinaryFloatingPoint, z: some BinaryFloatingPoint) {
//    self.init(x: Float(x), y: Float(y), z: Float(z))
//  }
//  
//  public init(x: some BinaryInteger, y: some BinaryInteger, z: some BinaryInteger) {
//    self.init(x: Float(x), y: Float(y), z: Float(z))
//  }
//}

public struct HelloRect3D<NumberType: HelloNumeric>: HelloRect3DConformable, Hashable, Codable, Sendable, CustomStringConvertible {
  
  public var origin: HelloPoint3D<NumberType>
  public var size: HelloSize3D<NumberType>
  
  public init(origin: HelloPoint3D<NumberType>, size: HelloSize3D<NumberType>) {
    self.origin = origin
    self.size = size
  }
  
  public init(origin: some HelloPoint3DConformable<NumberType>, size: some HelloSize3DConformable<NumberType>) {
    self.origin = HelloPoint3D(x: origin.x, y: origin.y, z: origin.z)
    self.size = HelloSize3D(width: size.width, height: size.height, depth: size.depth)
  }
  
  public init(origin: some HelloPoint3DConformable<NumberType>, size: some HelloPoint3DConformable<NumberType>) {
    self.origin = HelloPoint3D(x: origin.x, y: origin.y, z: origin.z)
    self.size = HelloSize3D(width: size.x, height: size.y, depth: size.z)
  }
  
  public init(x: NumberType, y: NumberType, z: NumberType,
              width: NumberType, height: NumberType, depth: NumberType) {
    self.origin = HelloPoint3D(x: x, y: y, z: z)
    self.size = HelloSize3D(width: width, height: height, depth: depth)
  }
  
  
  
  public mutating func move(to newOrigin: some HelloPoint3DConformable<NumberType>) {
    self.origin = HelloPoint3D(x: newOrigin.x, y: newOrigin.y, z: newOrigin.z)
  }
  
  public func padded(with padding: NumberType) -> Self {
    HelloRect3D(origin: origin, size: size + 2 * padding)
  }
  
  public func contains(point: some HelloPoint3DConformable<NumberType>) -> Bool {
    let halfSize = NumberType(0.5) * size
    return point.z > origin.z - halfSize.depth && point.z < origin.z + halfSize.depth &&
    point.x > origin.x - halfSize.width && point.x < origin.x + halfSize.width &&
    point.y > origin.y - halfSize.height && point.y < origin.y + halfSize.height
  }
  
  public var description: String { "((\(x), \(y), \(z)), (\(width), \(height), \(depth)))" }
  
  public var backCenter: HelloPoint3D<NumberType> {
    HelloPoint3D(x: x, y: y, z: z - NumberType(0.5) * depth)
  }
}

public protocol HelloRect3DConformable {
  
  associatedtype NumberType: HelloNumeric
  associatedtype PointType: HelloPoint3DConformable<NumberType>
  associatedtype SizeType: HelloSize3DConformable<NumberType>
  
  var origin: PointType { get set }
  var size: SizeType { get set }
  
  init(origin: PointType, size: SizeType)
  init(x: NumberType, y: NumberType, z: NumberType, 
       width: NumberType, height: NumberType, depth: NumberType)
}

public extension HelloRect3DConformable {
  
  public var x: NumberType { origin.x }
  public var y: NumberType { origin.y }
  public var z: NumberType { origin.z }
  public var width: NumberType { size.width }
  public var height: NumberType { size.height }
  public var depth: NumberType { size.depth }
  
  public var minX: NumberType { origin.x - width / 2 }
  public var minY: NumberType { origin.y - height / 2 }
  public var minZ: NumberType { origin.z - depth / 2 }
  
  public var maxX: NumberType { origin.x + width / 2 }
  public var maxY: NumberType { origin.y + height / 2 }
  public var maxZ: NumberType { origin.z + depth / 2 }
  
  public var minPoint: HelloPoint3D<NumberType> {
    HelloPoint3D(x: minX, y: minY, z: minZ)
  }
  
  public var maxPoint: HelloPoint3D<NumberType> {
    HelloPoint3D(x: maxX, y: maxY, z: maxZ)
  }
}
