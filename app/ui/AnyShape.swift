import SwiftUI

public struct AnyShape: Shape {
  private let base: @Sendable (CGRect) -> Path
  
  public init<S: Shape>(_ shape: S) {
    base = shape.path(in:)
  }
  
  public func path(in rect: CGRect) -> Path {
    base(rect)
  }
}

public struct AnyInsettableShape: InsettableShape {
  
  nonisolated private let base: @Sendable (CGRect) -> Path
  private var insetAmount: CGFloat = 0
  
  public init<S: InsettableShape>(_ shape: S) {
    base = shape.path(in:)
    insetAmount = 0
  }
  
  public init(path: @escaping @Sendable (CGRect) -> Path, insetAmount: CGFloat = 0) {
    base = path
    self.insetAmount = insetAmount
  }
  
  nonisolated public func inset(by amount: CGFloat) -> AnyInsettableShape {
    var copy = self
    copy.insetAmount = amount
    return copy
  }
  
  public func path(in rect: CGRect) -> Path {
    base(rect.insetBy(dx: insetAmount, dy: insetAmount))
  }
}

public extension AnyInsettableShape {
  static var circle: AnyInsettableShape {
    AnyInsettableShape(.circle)
  }
  
  static var capsule: AnyInsettableShape {
    AnyInsettableShape(.capsule)
  }
  
  static var rect: AnyInsettableShape {
    AnyInsettableShape(.rect)
  }
  
  static func rect(cornerRadius: CGFloat) -> AnyInsettableShape {
    AnyInsettableShape(.rect(cornerRadius: cornerRadius))
  }
  
  static func rect(cornerRadii: RectangleCornerRadii) -> AnyInsettableShape {
    AnyInsettableShape(.rect(cornerRadii: cornerRadii))
  }
}
