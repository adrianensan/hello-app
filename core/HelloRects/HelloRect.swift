import Foundation

public protocol HelloNumeric: CustomStringConvertible, Hashable, Numeric, Sendable, Codable, Strideable where Self.Magnitude : HelloNumeric, Self.Magnitude == Self.Magnitude.Magnitude {
  init(_ source: some BinaryInteger)
  init(_ source: some BinaryFloatingPoint)
  
  static func + (lhs: Self, rhs: Self) -> Self
  static func - (lhs: Self, rhs: Self) -> Self
  static func / (lhs: Self, rhs: Self) -> Self
  static func /= (lhs: inout Self, rhs: Self)
//  init(_ source: some BinaryFloatingPoint)
}

//public extension FloatingPoint {
//  static var tau: Self { 2 * .pi }
//}

extension Int: HelloNumeric {}
extension UInt: HelloNumeric {}
extension Int64: HelloNumeric {}
extension UInt32: HelloNumeric {}
extension UInt64: HelloNumeric {}

extension Float: HelloNumeric {}
extension Double: HelloNumeric {}
extension CGFloat: HelloNumeric {}

public extension HelloNumeric {
  var normalized: Self { self < 0 ? -1 : 1 }
}

public typealias IntPoint = HelloPoint<Int>
public typealias IntSize = HelloSize<Int>
public typealias IntRect = HelloRect<Int>

public typealias FloatPoint = HelloPoint<Float>
public typealias FloatSize = HelloSize<Float>
public typealias FloatRect = HelloRect<Float>

public typealias DoublePoint = HelloPoint<Double>
public typealias DoubleSize = HelloSize<Double>
public typealias DoubleRect = HelloRect<Double>

extension SIMD2<Float>: HelloPointConformable {
  public init(x: some BinaryFloatingPoint, y: some BinaryFloatingPoint) {
    self.init(x: Float(x), y: Float(y))
  }
  
  public init(x: some BinaryInteger, y: some BinaryInteger) {
    self.init(x: Float(x), y: Float(y))
  }
}

extension CGPoint: HelloPointConformable {
  public init(x: some BinaryFloatingPoint, y: some BinaryFloatingPoint) {
    self.init(x: CGFloat(x), y: CGFloat(y))
  }
  
  public init(x: some BinaryInteger, y: some BinaryInteger) {
    self.init(x: CGFloat(x), y: CGFloat(y))
  }
}

extension CGSize: HelloSizeConformable {
  public init(width: some BinaryFloatingPoint, height: some BinaryFloatingPoint) {
    self.init(width: CGFloat(width), height: CGFloat(height))
  }
  
  public init(width: some BinaryInteger, height: some BinaryInteger) {
    self.init(width: CGFloat(width), height: CGFloat(height))
  }
}

extension CGRect: HelloRectConformable {
  public typealias NumberType = CGFloat
}

public struct HelloPoint<NumberType: HelloNumeric>: HelloPointConformable, Hashable, Codable, Sendable, CustomStringConvertible {
  
  public static var zero: Self { Self(x: 0, y: 0) }
  
  public var x: NumberType
  public var y: NumberType
  
  public init(x: NumberType, y: NumberType) {
    self.x = x
    self.y = y
  }
  
  public init(x: some BinaryInteger, y: some BinaryInteger) {
    self.x = NumberType(x)
    self.y = NumberType(y)
  }
  
  public init(x: some BinaryFloatingPoint, y: some BinaryFloatingPoint) {
    self.x = NumberType(x)
    self.y = NumberType(y)
  }
  
  public var description: String { "(\(x), \(y))" }
}

public struct HelloSize<NumberType: HelloNumeric>: HelloSizeConformable, Hashable, Codable, Sendable, CustomStringConvertible {
  
  public static var zero: Self { Self(width: 0, height: 0) }
  
  public var width: NumberType
  public var height: NumberType
  
  public init(width: NumberType, height: NumberType) {
    self.width = width
    self.height = height
  }
  
  public init(width: some BinaryInteger, height: some BinaryInteger) {
    self.width = NumberType(width)
    self.height = NumberType(height)
  }
  
  public init(width: some BinaryFloatingPoint, height: some BinaryFloatingPoint) {
    self.width = NumberType(width)
    self.height = NumberType(height)
  }
  
  public var description: String { "(\(width), \(height))" }
}

public struct HelloRect<NumberType: HelloNumeric>: HelloRectConformable, Hashable, Codable, Sendable, CustomStringConvertible {
  
  public var origin: HelloPoint<NumberType>
  public var size: HelloSize<NumberType>
  
  public init(origin: HelloPoint<NumberType>, size: HelloSize<NumberType>) {
    self.origin = origin
    self.size = size
  }
  
  public init(origin: some HelloPointConformable<NumberType>, size: some HelloSizeConformable<NumberType>) {
    self.origin = HelloPoint(x: origin.x, y: origin.y)
    self.size = HelloSize(width: size.width, height: size.height)
  }
  
  public init(x: NumberType, y: NumberType, width: NumberType, height: NumberType) {
    self.origin = HelloPoint(x: x, y: y)
    self.size = HelloSize(width: width, height: height)
  }
  
  public var x: NumberType { origin.x }
  public var y: NumberType { origin.y }
  public var width: NumberType { size.width }
  public var height: NumberType { size.height }
  
  public var description: String { "((\(x), \(y)), (\(width), \(height)))" }
}

//extension HelloPoint {
////  func rotate(by radians: Double) -> Self {
////    Self.init(x: Double(x) * cos(Double(radians)) - Double(y) * sin(Double(radians)),
////              y: Double(x) * sin(Double(radians)) + Double(y) * cos(Double(radians)))
////  }
//}
