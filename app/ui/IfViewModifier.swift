import SwiftUI

public extension View {
  @ViewBuilder
  func `if`(_ condition: Bool, @ViewBuilder view: @MainActor (Self) -> some View) -> some View {
    if condition {
      view(self)
    } else {
      self
    }
  }
}
