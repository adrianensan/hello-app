import CoreGraphics

//public func round(_ cgRect: CGRect) -> CGRect {
//  CGRect(origin: round(cgRect.origin), size: round(cgRect.size))
//}

public extension CGRect {
    
////  func contains(_ innerRect: CGRect) -> Bool {
////    innerRect.origin.x >= origin.x &&
////    innerRect.origin.y >= origin.y &&
////    (innerRect.origin.x + innerRect.size.width) <= (origin.x + size.width) &&
////    (innerRect.origin.y + innerRect.size.height) <= (origin.y + size.height)
////  }
//  
//  func clipped(in outerSize: CGSize) -> CGRect {
//    var clippedRect = self
//    
//    if clippedRect.origin.x < 0 {
//      clippedRect.origin.x = 0
//    }
//    if clippedRect.origin.x + clippedRect.size.width > outerSize.width {
//      clippedRect.size.width = outerSize.width - clippedRect.origin.x
//    }
//    
//    if clippedRect.origin.y < 0 {
//      clippedRect.origin.y = 0
//    }
//    if clippedRect.origin.y + clippedRect.size.height > outerSize.height {
//      clippedRect.size.height = outerSize.height - clippedRect.origin.y
//    }
//    
//    return clippedRect
//  }
//  
//  func fit(in outerSize: CGSize) -> CGRect {
//    var clippedRect = self
//    
//    if clippedRect.origin.x < 0 {
//      clippedRect.size.width = min(outerSize.width, clippedRect.size.width + clippedRect.origin.x)
//      clippedRect.origin.x = 0
//    }
//    if clippedRect.origin.x + clippedRect.size.width > outerSize.width {
//      clippedRect.origin.x = max(0, clippedRect.origin.x - (clippedRect.origin.x + clippedRect.size.width - outerSize.width))
//      clippedRect.size.width = outerSize.width - clippedRect.origin.x
//    }
//    
//    if clippedRect.origin.y < 0 {
//      clippedRect.size.height = min(outerSize.height, clippedRect.size.height + clippedRect.origin.y)
//      clippedRect.origin.y = 0
//    }
//    if clippedRect.origin.y + clippedRect.size.height > outerSize.height {
//      clippedRect.origin.y = max(0, clippedRect.origin.y - (clippedRect.origin.y + clippedRect.size.height - outerSize.height))
//      clippedRect.size.height = outerSize.height - clippedRect.origin.y
//    }
//    
//    return clippedRect
//  }
  
  func squaredOff(in outerSize: CGSize) -> CGRect {
    var newRect = self
    let heightToAdd = size.width - size.height
    let widthToAdd = size.height - size.width
    if heightToAdd > 0 {
      let xStartAvailable = origin.y
      let xEndAvailable = outerSize.height - origin.y - size.height
      newRect.origin.y -= min(xStartAvailable, 0.5 * heightToAdd + max(0, 0.5 * heightToAdd - xEndAvailable))
      newRect.size.height += min(xStartAvailable + xEndAvailable, heightToAdd)
    } else if widthToAdd > 0 {
      let yStartAvailable = origin.x
      let yEndAvailable = outerSize.width - origin.x - size.width
      newRect.origin.x -= min(yStartAvailable, 0.5 * widthToAdd + max(0, 0.5 * widthToAdd - yEndAvailable))
      newRect.size.width += min(yStartAvailable + yEndAvailable, widthToAdd)
    }
    
    let widthToRemove = newRect.size.width - newRect.size.height
    let heightToRemove = newRect.size.height - newRect.size.width
    
    if heightToRemove > 0 {
      newRect.origin.y += 0.5 * heightToRemove
      newRect.size.height -= heightToRemove
    } else if widthToRemove > 0 {
      newRect.origin.x += 0.5 * widthToRemove
      newRect.size.width -= widthToRemove
    }
    
    
    return newRect
  }
  
//  func with(padding: CGFloat.NativeType, within sizeLimit: CGSize) -> CGRect {
//    var newRect = self
//    let maxXPadding = max(0, min(padding,
//                          newRect.origin.x,
//                          sizeLimit.width - newRect.size.width - newRect.origin.x))
//    if maxXPadding > 0 {
//      newRect.origin.x -= maxXPadding
//      newRect.size.width += 2 * maxXPadding
//    }
//    
//    let maxYPadding = max(0, min(padding,
//                          newRect.origin.y,
//                          sizeLimit.height - newRect.size.height - newRect.origin.y))
//    if maxYPadding > 0 {
//      newRect.origin.y -= maxYPadding
//      newRect.size.height += 2 * maxYPadding
//    }
//    return newRect
//  }
  
  func mapped(to targetRect: CGRect, with maxPadding: CGFloat.NativeType) -> CGRect {
    var newRect = CGRect()
    newRect.origin.x = max(0, round(origin.x * targetRect.origin.x))
    newRect.origin.y = max(0, round(origin.y * targetRect.origin.y))
    newRect.size.width = min(targetRect.size.width - newRect.origin.x, round(size.width * targetRect.size.width))
    newRect.size.height = min(targetRect.size.height - newRect.origin.y, round(size.height * targetRect.size.height))
    if Int(newRect.size.width) % 2 != 0 {
      newRect.size.width -= 1
    }
    if Int(newRect.size.height) % 2 != 0 {
      newRect.size.height -= 1
    }
    return newRect
  }
  
  var imageCompatible: CGRect {
    var newRect = self
    newRect.origin.x = round(newRect.origin.x)
    newRect.origin.y = round(newRect.origin.y)
    newRect.size.width = round(newRect.size.width)
    newRect.size.height = round(newRect.size.width)
    if Int(newRect.size.width) % 2 != 0 {
      newRect.size.width -= 1
    }
    if Int(newRect.size.height) % 2 != 0 {
      newRect.size.height -= 1
    }
    return newRect
  }
  
  func clippedHorizontally(in outerRect: CGRect) -> CGRect {
    var clippedRect = self
    
    let minXDiff = outerRect.minX - clippedRect.minX
    if minXDiff > 0 {
      clippedRect.origin.x = outerRect.minX
      clippedRect.size.width = max(0, clippedRect.width - minXDiff)
    }
    
    let maxXDiff = clippedRect.maxX - outerRect.maxX
    if maxXDiff > 0 {
      clippedRect.size.width = max(0, clippedRect.width - maxXDiff)
    }
    
    return clippedRect
  }
  
  func clippedVertically(in outerRect: CGRect) -> CGRect {
    var clippedRect = self
    
    let minYDiff = outerRect.minY - clippedRect.minY
    if minYDiff > 0 {
      clippedRect.origin.y = outerRect.minY
      clippedRect.size.height = max(0, clippedRect.height - minYDiff)
    }
    
    let maxYDiff = clippedRect.maxY - outerRect.maxY
    if maxYDiff > 0 {
      clippedRect.size.height = max(0, clippedRect.height - maxYDiff)
    }
    
    return clippedRect
  }
  
  func fitVertically(in outerRect: CGRect) -> CGRect {
    var clippedRect = self
    
    let minYDiff = outerRect.minY - clippedRect.minY
    if minYDiff > 0 {
      clippedRect.origin.y = outerRect.minY
      clippedRect.size.height = max(outerRect.height, clippedRect.height)
    }
    
    let maxYDiff = clippedRect.maxY - outerRect.maxY
    if maxYDiff > 0 {
      clippedRect.origin.y = max(outerRect.minY, clippedRect.minY - maxYDiff)
      clippedRect.size.height = max(outerRect.height, clippedRect.height)
    }
    
    return clippedRect
  }
  
  func clipped(in outerRect: CGRect) -> CGRect {
    var clippedRect = self
    
    let minXDiff = outerRect.minX - clippedRect.minX
    if minXDiff > 0 {
      clippedRect.origin.x = outerRect.minX
      clippedRect.size.width = max(0, clippedRect.width - minXDiff)
    }
    
    let maxXDiff = clippedRect.maxX - outerRect.maxX
    if maxXDiff > 0 {
      clippedRect.size.width = max(0, clippedRect.width - maxXDiff)
    }
    
    let minYDiff = outerRect.minY - clippedRect.minY
    if minYDiff > 0 {
      clippedRect.origin.y = outerRect.minY
      clippedRect.size.height = max(0, clippedRect.height - minYDiff)
    }
    
    let maxYDiff = clippedRect.maxY - outerRect.maxY
    if maxYDiff > 0 {
      clippedRect.size.height = max(0, clippedRect.height - maxYDiff)
    }
    
    return clippedRect
  }
}
