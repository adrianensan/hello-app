import Foundation

public protocol HelloNumeric: CustomStringConvertible, Hashable, Numeric, Sendable, Codable, CVarArg, Strideable where Self.Magnitude : HelloNumeric, Self.Magnitude == Self.Magnitude.Magnitude {
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

public extension HelloNumeric where Self: BinaryFloatingPoint {
  var string: String {
    String(format: "%.2f", self).deletingSuffix("0").deletingSuffix(".0")
  }
}
