import SwiftUI

public extension View {
  @ViewBuilder
  func optionalPosition(_ point: CGPoint?) -> some View {
    if let point {
      position(point)
    } else {
      self
    }
  }
}
