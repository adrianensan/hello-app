import Foundation

public struct HelloSize3D<NumberType: HelloNumeric>: HelloSize3DConformable, Hashable, Codable, Sendable, CustomStringConvertible {
  
  public static var zero: Self { Self(width: 0, height: 0, depth: 0) }
  
  public var width: NumberType
  public var height: NumberType
  public var depth: NumberType
  
  public init(width: NumberType, height: NumberType, depth: NumberType) {
    self.width = width
    self.height = height
    self.depth = depth
  }
  
  public init(width: some BinaryInteger, height: some BinaryInteger, depth: some BinaryInteger) {
    self.width = NumberType(width)
    self.height = NumberType(height)
    self.depth = NumberType(depth)
  }
  
  public init(width: some BinaryFloatingPoint, height: some BinaryFloatingPoint, depth: some BinaryFloatingPoint) {
    self.width = NumberType(width)
    self.height = NumberType(height)
    self.depth = NumberType(depth)
  }
  
  public var description: String { "(\(width), \(height), \(depth))" }
}

public protocol HelloSize3DConformable<NumberType> {
  
  associatedtype NumberType: HelloNumeric
  
  var width: NumberType { get set }
  var height: NumberType { get set }
  var depth: NumberType { get set }
  
  init(width: NumberType, height: NumberType, depth: NumberType)
}

public extension HelloSize3DConformable {
  static func *(left: Self, right: NumberType) -> Self {
    Self(width: left.width * right, height: left.height * right, depth: left.depth * right)
  }
  
  static func *(left: NumberType, right: Self) -> Self {
    right * left
  }
  
  static func +(left: Self, right: NumberType) -> Self {
    Self(width: left.width + right, height: left.height + right, depth: left.depth + right)
  }
  
  static func +(left: NumberType, right: Self) -> Self {
    right * left
  }
}

public extension HelloSize3DConformable where NumberType: BinaryFloatingPoint {
  var simdFloat: SIMD3<Float> {
    SIMD3(x: Float(width), y: Float(height), z: Float(depth))
  }
}

//extension SIMD3<Float>: HelloSize3DConformable {
//  public var width: Float {
//    get { x }
//    set { x = newValue }
//  }
//  
//  public var height: Float {
//    get { y }
//    set { y = newValue }
//  }
//  
//  public var depth: Float {
//    get { z }
//    set { z = newValue }
//  }
//  
//  public init(width: NumberType, height: NumberType, depth: NumberType) {
//    self.init(width: Float(width), height: Float(height), depth: Float(depth))
//  }
//}
