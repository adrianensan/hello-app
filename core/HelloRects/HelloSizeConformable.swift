import Foundation

public protocol HelloSizeConformable<NumberType> {
  
  associatedtype NumberType: HelloNumeric
  
  var width: NumberType { get set }
  var height: NumberType { get set }
  
  init(width: NumberType, height: NumberType)
  init(width: some BinaryInteger, height: some BinaryInteger)
  init(width: some BinaryFloatingPoint, height: some BinaryFloatingPoint)
}

public extension HelloSizeConformable {
  
  static func +(left: Self, right: Self) -> Self {
    Self(width: left.width + right.width, height: left.height + right.height)
  }
  
  static func -(left: Self, right: Self) -> Self {
    Self(width: left.width - right.width, height: left.height - right.height)
  }
  
  static func *(left: Self, right: Self) -> Self {
    Self(width: left.width * right.width, height: left.height * right.height)
  }
  
  static func /(left: Self, right: Self) -> Self {
    Self(width: left.width / right.width, height: left.height / right.height)
  }
  
  static func *(left: Self, right: NumberType) -> Self {
    Self(width: left.width * right, height: left.height * right)
  }
  
  static func *(left: NumberType, right: Self) -> Self {
    Self(width: left * right.width, height: left * right.height)
  }
  
  static func /(left: Self, right: NumberType) -> Self {
    Self(width: left.width / right, height: left.height / right)
  }
  
  static func +(left: Self, right: NumberType) -> Self {
    Self(width: left.width + right, height: left.height + right)
  }
  
  static func -(left: Self, right: NumberType) -> Self {
    Self(width: left.width - right, height: left.height - right)
  }
  
  var minSide: NumberType { min(width, height) }
  
  var maxSide: NumberType { max(width, height) }
  
  var maxDimension: NumberType { max(width, height) }
  
  var center: HelloPoint<NumberType> { HelloPoint<NumberType>(x: width / 2, y: height / 2) }
  
  var centeredRect: HelloRect<NumberType> { HelloRect<NumberType>(origin: center, size: self) }
  
  var zeroedRect: HelloRect<NumberType> { HelloRect<NumberType>(origin: .zero, size: HelloSize<NumberType>(width: width, height: height)) }
  
  func sizeThatFits(with aspectRatio: NumberType) -> Self {
    let currentAspectRatio = height / width
    if currentAspectRatio > aspectRatio {
      return Self(width: width, height: width * aspectRatio)
    } else if currentAspectRatio < aspectRatio {
      return Self(width: height / aspectRatio, height: height)
    } else {
      return self
    }
  }
  
  func padded(by padding: NumberType) -> Self {
    self - padding - padding
  }
}

public extension HelloSizeConformable where NumberType: BinaryInteger {
  
  var doubleSize: DoubleSize { DoubleSize(width: Double(width), height: Double(height)) }
  var floatSize: FloatSize { FloatSize(width: Float(width), height: Float(height)) }
  var size3D: SIMD3<Float> { SIMD3(x: Float(width), y: Float(height), z: 0) }
  
  var diagonal: Double { magnitude }
  var magnitude: Double { doubleSize.diagonal }
  
  var center: HelloPoint<Double> { doubleSize.center }
}

public extension HelloSizeConformable where NumberType: BinaryFloatingPoint {
  var magnitude: Double { sqrt(Double(width * width + height * height)) }
  var diagonal: Double { magnitude }
}

public extension HelloSizeConformable where Self == CGSize {
  var center: CGPoint { CGPoint(x: width / 2, y: height / 2) }
  
  var zeroedRect: CGRect { CGRect(origin: .zero, size: CGSize(width: width, height: height)) }
}

public func round<SizeType: HelloSizeConformable>(_ size: SizeType) -> SizeType where SizeType.NumberType: BinaryFloatingPoint {
  SizeType(width: SizeType.NumberType(round(Double(size.width))),
           height: SizeType.NumberType(round(Double(size.height))))
}

public func abs<SizeType: HelloSizeConformable>(_ size: SizeType) -> SizeType where SizeType.NumberType: BinaryFloatingPoint {
  SizeType(width: SizeType.NumberType(abs(Double(size.width))),
           height: SizeType.NumberType(abs(Double(size.height))))
}

public func abs<SizeType: HelloSizeConformable>(_ size: SizeType) -> SizeType where SizeType.NumberType: BinaryInteger {
  SizeType(width: SizeType.NumberType(abs(Double(size.width))),
           height: SizeType.NumberType(abs(Double(size.height))))
}
