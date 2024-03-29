import SwiftUI

public extension View {
  func offset(_ point: CGPoint) -> some View {
    offset(x: point.x, y: point.y)
  }
  
  @ViewBuilder
  func optionalPosition(_ point: CGPoint?) -> some View {
    if let point {
      position(point)
    } else {
      self
    }
  }
}
