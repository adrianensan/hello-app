import Foundation

public extension CGSize {
  
  static var unit: CGSize { CGSize(width: 1, height: 1) }
  
  var diagonal: CGFloat { CGFloat(sqrt(width * width + height * height)) }
  
  var minSide: CGFloat { CGFloat(min(width, height)) }
  
  var maxSide: CGFloat { CGFloat(max(width, height)) }
  
  var maxSideMagnitude: CGFloat { CGFloat(max(abs(width), abs(height))) }
  
  var center: CGPoint { CGPoint(x: 0.5 * width, y: 0.5 * height) }
  
  var centeredRect: CGRect { CGRect(origin: center, size: self) }
  
  var zeroedRect: CGRect { CGRect(origin: .init(), size: self) }
  
  var rounded: CGSize { CGSize(width: round(width), height: round(height)) }
  
  static prefix func -(point: CGSize) -> CGSize {
    point * -1
  }
  
  static func +(left: CGSize, right: CGSize) -> CGSize {
    CGSize(width: left.width + right.width, height: left.height + right.height)
  }
  
  static func -(left: CGSize, right: CGSize) -> CGSize {
    CGSize(width: left.width - right.width, height: left.height - right.height)
  }
  
  static func *(left: CGSize, right: CGSize) -> CGSize {
    CGSize(width: left.width * right.width, height: left.height * right.height)
  }
  
  static func /(left: CGSize, right: CGSize) -> CGSize {
    CGSize(width: left.width / right.width, height: left.height / right.height)
  }
  
  // Constants Math
  
  static func *(left: CGSize, right: CGFloat.NativeType) -> CGSize {
    CGSize(width: left.width * right, height: left.height * right)
  }
  
  static func *(left: CGFloat.NativeType, right: CGSize) -> CGSize {
    CGSize(width: left * right.width, height: left * right.height)
  }
  
  static func /(left: CGSize, right: CGFloat.NativeType) -> CGSize {
    CGSize(width: left.width / right, height: left.height / right)
  }
}
