import SwiftUI

public struct WindowAnchor {
  public var point: CGPoint
  public var alignment: Alignment
  public var offset: CGFloat = 0
  
  public init(point: CGPoint, alignment: Alignment, offset: CGFloat = 0) {
    self.point = point
    self.alignment = alignment
    self.offset = offset
  }
}
