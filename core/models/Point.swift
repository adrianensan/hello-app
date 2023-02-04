import Foundation

public struct Point: Codable, Equatable, Hashable, Sendable {
  public var x: Double
  public var y: Double
  
  public init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }
}

public extension Point {
  static var zero: Point { Point(x: 0, y: 0) }
  
  var cgPoint: CGPoint { CGPoint(x: x, y: y) }
}
