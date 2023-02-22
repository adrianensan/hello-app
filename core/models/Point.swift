import Foundation

public struct Point: Codable, Equatable, Hashable, Sendable {
  public var x: Double
  public var y: Double
  
  public init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }
}

public struct Size: Codable, Equatable, Hashable, Sendable {
  public var width: Double
  public var height: Double
  
  public init(width: Double, height: Double) {
    self.width = width
    self.height = height
  }
}

public struct Rect: Codable, Equatable, Hashable, Sendable {
  public var point: Point
  public var size: Size
  
  public init(point: Point, size: Size) {
    self.point = point
    self.size = size
  }
}

public extension Point {
  static var zero: Point { Point(x: 0, y: 0) }
  
  var cgPoint: CGPoint { CGPoint(x: x, y: y) }
}

public extension Size {
  static var zero: Size { Size(width: 0, height: 0) }
  
//  #if os(watchOS)
//  var cgSize: CGSize { CGSize(width: Float(width), height: Float(height)) }
//  #else
  var cgSize: CGSize { CGSize(width: CGFloat.NativeType(width),
                              height: CGFloat.NativeType(height)) }
//  #endif
}

public extension Rect {
  static var zero: Rect { Rect(point: .zero, size: .zero) }
  
  var cgRect: CGRect { CGRect(origin: point.cgPoint, size: size.cgSize) }
  
  var x: Double { point.x }
  var y: Double { point.y }
  
  var width: Double { size.width }
  var height: Double { size.height }
}
