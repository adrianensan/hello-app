import Foundation

public protocol HelloRectConformable {
  
  associatedtype NumberType: HelloNumeric
  associatedtype PointType: HelloPointConformable<NumberType>
  associatedtype SizeType: HelloSizeConformable<NumberType>
  
  var origin: PointType { get set }
  var size: SizeType { get set }
  
  init(origin: PointType, size: SizeType)
  init(x: NumberType, y: NumberType, width: NumberType, height: NumberType)
}

public extension HelloRectConformable {
  
  static func +(left: Self, right: Self) -> Self {
    Self(x: left.origin.x + right.origin.x,
         y: left.origin.y + right.origin.y,
         width: left.size.width + right.size.width,
         height: left.size.height + right.size.height)
  }
  
  static func -(left: Self, right: Self) -> Self {
    Self(x: left.origin.x - right.origin.x,
         y: left.origin.y - right.origin.y,
         width: left.size.width - right.size.width,
         height: left.size.height - right.size.height)
  }
  
  static func +(left: Self, right: PointType) -> Self {
    Self(origin: PointType(x: left.origin.x + right.x,
                           y: left.origin.y + right.y),
         size: left.size)
  }
  
  static func -(left: Self, right: PointType) -> Self {
    Self(origin: PointType(x: left.origin.x - right.x,
                           y: left.origin.y - right.y),
         size: left.size)
  }
  
  static func /(left: Self, right: NumberType) -> Self {
    Self(x: left.origin.x / right,
         y: left.origin.y / right,
         width: left.size.width / right,
         height: left.size.height / right)
  }
  
  var x: NumberType { origin.x }
  var y: NumberType { origin.y }
  
  var width: NumberType { size.width }
  var height: NumberType { size.height }
  
  var minX: NumberType { x }
  var minY: NumberType { y }
  
  var midX: NumberType { x + width / 2 }
  var midY: NumberType { y + height / 2 }
  
  var maxX: NumberType { x + width }
  var maxY: NumberType { y + height }
  
  var center: PointType {
    PointType(x: midX, y: midY)
  }
  
  var leading: PointType {
    PointType(x: minX, y: midY)
  }
  
  var topLeading: PointType {
    PointType(x: minX, y: maxY)
  }
  
  var topTrailing: PointType {
    PointType(x: maxX, y: maxY)
  }
  
  var trailing: PointType {
    PointType(x: maxX, y: midY)
  }
  
  var bottom: PointType {
    PointType(x: midX, y: maxY)
  }
  
  var bottomLeading: PointType {
    PointType(x: minX, y: minY)
  }
  
  var bottomTrailing: PointType {
    PointType(x: maxX, y: minY)
  }
  
  var top: PointType {
    PointType(x: midX, y: minY)
  }
  
  func clipped(in outerSize: SizeType) -> Self {
    var clippedRect = self
    
    if clippedRect.origin.x < 0 {
      clippedRect.origin.x = 0
    }
    if clippedRect.maxX > outerSize.width {
      clippedRect.size.width = outerSize.width - clippedRect.origin.x
    }
    
    if clippedRect.origin.y < 0 {
      clippedRect.origin.y = 0
    }
    if clippedRect.maxY > outerSize.height {
      clippedRect.size.height = outerSize.height - clippedRect.origin.y
    }
    
    return clippedRect
  }
  
  func fit(in outerSize: SizeType) -> Self {
    var clippedRect = self
    
    if clippedRect.origin.x < 0 {
      clippedRect.size.width = min(outerSize.width, clippedRect.maxX)
      clippedRect.origin.x = 0
    }
    if clippedRect.maxX > outerSize.width {
      clippedRect.origin.x = max(0, clippedRect.origin.x - (maxX - outerSize.width))
      clippedRect.size.width = outerSize.width - clippedRect.origin.x
    }
    
    if clippedRect.origin.y < 0 {
      clippedRect.size.height = min(outerSize.height, clippedRect.maxY)
      clippedRect.origin.y = 0
    }
    if clippedRect.maxY > outerSize.height {
      clippedRect.origin.y = max(0, clippedRect.origin.y - (clippedRect.maxY - outerSize.height))
      clippedRect.size.height = outerSize.height - clippedRect.origin.y
    }
    
    return clippedRect
  }
  
  public func padded(by padding: NumberType) -> Self {
    var paddedRect = self
    paddedRect.origin.x += padding
    paddedRect.origin.y += padding
    paddedRect.size.width -= 2 * padding
    paddedRect.size.height -= 2 * padding
    return paddedRect
  }
}

public func round<RectType: HelloRectConformable>(_ rect: RectType) -> RectType where RectType.NumberType: BinaryFloatingPoint {
  RectType(x: RectType.NumberType(round(Double(rect.x))),
           y: RectType.NumberType(round(Double(rect.y))),
           width: RectType.NumberType(round(Double(rect.width))),
           height: RectType.NumberType(round(Double(rect.height))))
}

public func abs<RectType: HelloRectConformable>(_ rect: RectType) -> RectType where RectType.NumberType: BinaryFloatingPoint {
  RectType(x: RectType.NumberType(abs(Double(rect.x))),
           y: RectType.NumberType(abs(Double(rect.y))),
           width: RectType.NumberType(abs(Double(rect.width))),
           height: RectType.NumberType(abs(Double(rect.height))))
}

public func abs<RectType: HelloRectConformable>(_ rect: RectType) -> RectType where RectType.NumberType: BinaryInteger {
  RectType(x: RectType.NumberType(abs(Double(rect.x))),
           y: RectType.NumberType(abs(Double(rect.y))),
           width: RectType.NumberType(abs(Double(rect.width))),
           height: RectType.NumberType(abs(Double(rect.height))))
}
