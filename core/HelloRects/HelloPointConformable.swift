import Foundation

public protocol HelloPointConformable<NumberType> {
  
  associatedtype NumberType: HelloNumeric
  
  var x: NumberType { get set }
  var y: NumberType { get set }
  
  init(x: NumberType, y: NumberType)
  init(x: some BinaryInteger, y: some BinaryInteger)
  init(x: some BinaryFloatingPoint, y: some BinaryFloatingPoint)
}

public extension HelloPointConformable {
  
  var minCoordinate: NumberType { min(x, y) }
  
  var maxCoordinate: NumberType { max(x, y) }
  
  static func +=(left: inout Self, right: Self) {
    left = left + right
  }
  
  static func -=(left: inout Self, right: Self) {
    left = left - right
  }
  
  static func +(left: Self, right: Self) -> Self {
    Self(x: left.x + right.x, y: left.y + right.y)
  }
  
  static func -(left: Self, right: Self) -> Self {
    Self(x: left.x - right.x, y: left.y - right.y)
  }
  
  static func *(left: Self, right: Self) -> Self {
    Self(x: left.x * right.x, y: left.y * right.y)
  }
  
  static func /(left: Self, right: Self) -> Self {
    Self(x: left.x / right.x, y: left.y / right.y)
  }
  
  // Constants Math
  
  static func +(left: Self, right: NumberType) -> Self {
    Self(x: left.x + right, y: left.y + right)
  }
  
  static func -(left: Self, right: NumberType) -> Self {
    Self(x: left.x - right, y: left.y - right)
  }
  
  static func *(left: Self, right: NumberType) -> Self {
    Self(x: left.x * right, y: left.y * right)
  }
  
  static func *(left: NumberType, right: Self) -> Self {
    Self(x: left * right.x, y: left * right.y)
  }
  
  static func /(left: Self, right: NumberType) -> Self {
    Self(x: left.x / right, y: left.y / right)
  }
  
  //Size
  
  static func +(left: Self, right: some HelloSizeConformable<NumberType>) -> Self {
    Self(x: left.x + right.width, y: left.y + right.height)
  }
  
  static func -(left: Self, right: some HelloSizeConformable<NumberType>) -> Self {
    Self(x: left.x - right.width, y: left.y - right.height)
  }

  static func *(left: Self, right: some HelloSizeConformable<NumberType>) -> Self {
    Self(x: left.x * right.width, y: left.y * right.height)
  }

  static func /(left: Self, right: some HelloSizeConformable<NumberType>) -> Self {
    Self(x: left.x / right.width, y: left.y / right.height)
  }
  
  var perpendicular: Self { Self(x: y, y: x) }
  
  func dot(with vector: Self) -> NumberType {
    x * vector.x + y * vector.y
  }
}

public extension HelloPointConformable where NumberType: BinaryInteger {
  
  static prefix func -(point: Self) -> Self {
    point * -1
  }
  
  var doublePoint: DoublePoint { DoublePoint(x: Double(x), y: Double(y)) }
  
  var magnitude: Double { doublePoint.magnitude }
  
  var normalized: DoublePoint { doublePoint.normalized }
  
  func rotate(by radians: Double) -> DoublePoint { doublePoint.rotate(by: radians) }
  
  func distance(to otherPoint: Self) -> Double {
    (self - otherPoint).magnitude
  }
}

public extension HelloPointConformable where NumberType: BinaryFloatingPoint {
  
  var magnitude: NumberType { sqrt(x * x + y * y) }
  
  var normalized: Self {
    if magnitude > 0 {
      self / magnitude
    } else {
      Self(x: 0, y: 0)
    }
  }
  
  func rotate(by radians: Double) -> Self {
    let sinValue: NumberType = NumberType(sin(radians))
    let cosValue: NumberType = NumberType(cos(radians))
    return Self(x: x * cosValue - y * sinValue,
                y: x * sinValue + y * cosValue)
  }
  
  func distance(to otherPoint: Self) -> NumberType {
    (self - otherPoint).magnitude
  }
}

public extension HelloPointConformable where NumberType: BinaryFloatingPoint {
  
  static prefix func -(point: Self) -> Self {
    point * NumberType(-1)
  }
  
  static func *(left: Self, right: HelloSize<NumberType>) -> Self {
    Self(x: left.x * right.width, y: left.y * right.height)
  }
  
  static func /(left: Self, right: HelloSize<NumberType>) -> Self {
    Self(x: left.x / right.width, y: left.y / right.height)
  }
  
  static func +(left: Self, right: HelloSize<NumberType>) -> Self {
    Self(x: left.x + right.width, y: left.y + right.height)
  }
  
  static func -(left: Self, right: HelloSize<NumberType>) -> Self {
    Self(x: left.x - right.width, y: left.y - right.height)
  }
}

public func round<PointType: HelloPointConformable>(_ point: PointType) -> PointType where PointType.NumberType: BinaryFloatingPoint {
  PointType(x: PointType.NumberType(round(Double(point.x))),
            y: PointType.NumberType(round(Double(point.y))))
}

public func abs<PointType: HelloPointConformable>(_ point: PointType) -> PointType where PointType.NumberType: BinaryFloatingPoint {
  PointType(x: PointType.NumberType(abs(Double(point.x))),
            y: PointType.NumberType(abs(Double(point.y))))
}

public func abs<PointType: HelloPointConformable>(_ point: PointType) -> PointType where PointType.NumberType: BinaryInteger {
  PointType(x: PointType.NumberType(abs(Double(point.x))),
            y: PointType.NumberType(abs(Double(point.y))))
}
