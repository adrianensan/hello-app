import SwiftUI

public struct AppIconShape: InsettableShape {
  
  var insetAmount: CGFloat = 0
  
  public init() {}
  
  public func inset(by amount: CGFloat) -> AppIconShape {
    var copy = self
    copy.insetAmount = amount
    return copy
  }
  
  public func path(in rect: CGRect) -> Path {
    var path = Path()
    
    var insetRect = rect
    insetRect.origin.x += insetAmount
    insetRect.origin.y += insetAmount
    insetRect.size.width -= 2 * insetAmount
    insetRect.size.height -= 2 * insetAmount
    
    path.addRoundedRect(in: insetRect,
                        cornerSize: CGSize(width: 0.2 * insetRect.width,
                                           height: 0.2 * insetRect.height),
                        style: .continuous)
    
    return path
  }
}

public struct MacAppIconShape: InsettableShape {
  
  var insetAmount: CGFloat = 0
  
  public init() {}
  
  public func inset(by amount: CGFloat) -> MacAppIconShape {
    var copy = self
    copy.insetAmount = amount
    return copy
  }
  
  public func path(in rect: CGRect) -> Path {
    var path = Path()
    
    var insetRect = rect
    insetRect.origin.x += insetAmount
    insetRect.origin.y += insetAmount
    insetRect.size.width -= 2 * insetAmount
    insetRect.size.height -= 2 * insetAmount
    
    path.addRoundedRect(in: insetRect,
                        cornerSize: CGSize(width: 0.22 * insetRect.width,
                                           height: 0.22 * insetRect.height),
                        style: .continuous)
    
    return path
  }
}
