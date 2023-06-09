import CoreGraphics

public func abs(_ point: CGPoint) -> CGPoint {
  CGPoint(x: abs(point.x), y: abs(point.y))
}

public func round(_ cgPoint: CGPoint) -> CGPoint {
  CGPoint(x: round(cgPoint.x), y: round(cgPoint.y))
}

public extension CGPoint {
  
  #if os(watchOS)
  public init(x: CGFloat, y: CGFloat) {
    self.init(x: x, y: y)
  }
  #endif
  
  var magnitude: CGFloat.NativeType { sqrt(x * x + y * y) }
  
  var maxCoordinateMagnitude: CGFloat.NativeType { max(abs(x), abs(y)) }
  
  var normalized: CGPoint {
    if magnitude > 0 {
      return self / magnitude
    } else {
      return CGPoint(x: CGFloat(0), y: CGFloat(0))
    }
  }
  
  var perpendicular: CGPoint {
    CGPoint(x: y, y: x)
  }
  
  static prefix func -(point: CGPoint) -> CGPoint {
    point * -1
  }
  
  static func +=(left: inout CGPoint, right: CGPoint) {
    left = left + right
  }
  
  static func -=(left: inout CGPoint, right: CGPoint) {
    left = left - right
  }
  
  static func +(left: CGPoint, right: CGPoint) -> CGPoint {
    CGPoint(x: left.x + right.x, y: left.y + right.y)
  }
  
  static func -(left: CGPoint, right: CGPoint) -> CGPoint {
    CGPoint(x: left.x - right.x, y: left.y - right.y)
  }
  
  static func *(left: CGPoint, right: CGPoint) -> CGPoint {
    CGPoint(x: left.x * right.x, y: left.y * right.y)
  }
  
  static func /(left: CGPoint, right: CGPoint) -> CGPoint {
    CGPoint(x: left.x / right.x, y: left.y / right.y)
  }
  
  static func *(left: CGPoint, right: CGSize) -> CGPoint {
    CGPoint(x: left.x * right.width, y: left.y * right.height)
  }
  
  static func /(left: CGPoint, right: CGSize) -> CGPoint {
    CGPoint(x: left.x / right.width, y: left.y / right.height)
  }
  
  static func +(left: CGPoint, right: CGSize) -> CGPoint {
    CGPoint(x: left.x + right.width, y: left.y + right.height)
  }
  
  static func -(left: CGPoint, right: CGSize) -> CGPoint {
    CGPoint(x: left.x - right.width, y: left.y - right.height)
  }
  
  // Constants Math
  
  static func +(left: CGPoint, right: CGFloat.NativeType) -> CGPoint {
    CGPoint(x: left.x + right, y: left.y + right)
  }
  
  static func -(left: CGPoint, right: CGFloat.NativeType) -> CGPoint {
    CGPoint(x: left.x - right, y: left.y - right)
  }
  
  static func *(left: CGPoint, right: CGFloat.NativeType) -> CGPoint {
    CGPoint(x: left.x * right, y: left.y * right)
  }
  
  static func *(left: CGFloat.NativeType, right: CGPoint) -> CGPoint {
    CGPoint(x: left * right.x, y: left * right.y)
  }
  
  static func /(left: CGPoint, right: CGFloat.NativeType) -> CGPoint {
    CGPoint(x: left.x / right, y: left.y / right)
  }
  
  func dot(with vector: CGPoint) -> CGFloat.NativeType {
    x * vector.x + y * vector.y
  }
  
  func rotate(by radians: CGFloat.NativeType) -> CGPoint {
    CGPoint(x: x * cos(radians) - y * sin(radians),
            y: x * sin(radians) + y * cos(radians))
  }
}
