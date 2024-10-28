import SwiftUI

public extension View {
  /// Conditionally modify a view
  @ViewBuilder
  func `if`(_ condition: Bool, @ViewBuilder view: @MainActor (Self) -> some View) -> some View {
    if condition {
      view(self)
    } else {
      self
    }
  }
}
