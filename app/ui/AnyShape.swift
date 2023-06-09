import SwiftUI

public struct AnyShape: Shape {
  private var base: (CGRect) -> Path
  
  public init<S: Shape>(_ shape: S) {
    base = shape.path(in:)
  }
  
  public func path(in rect: CGRect) -> Path {
    base(rect)
  }
}

public struct AnyInsettableShape: InsettableShape {
  
  private var base: (CGRect) -> Path
  private var insetAmount: CGFloat = 0
  
  public init<S: InsettableShape>(_ shape: S) {
    base = shape.path(in:)
  }
  
  public func inset(by amount: CGFloat) -> AnyInsettableShape {
    var copy = self
    copy.insetAmount = amount
    return copy
  }
  
  public func path(in rect: CGRect) -> Path {
    base(rect.insetBy(dx: insetAmount, dy: insetAmount))
  }
}
