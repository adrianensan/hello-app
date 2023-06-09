#if os(macOS)
import SwiftUI

fileprivate struct ClosableByEscapeViewModifier: ViewModifier {
  
  @EnvironmentObject var windowModel: OFWindowModel
  
  func body(content: Content) -> some View {
    content.background(
      Button(action: {
        windowModel.window?.close()
      }) {
        Color.clear
      }.keyboardShortcut(.cancelAction)
        .opacity(0))
  }
}

@MainActor
public extension View {
  func closableByEscape() -> some View {
    self.modifier(ClosableByEscapeViewModifier())
  }
}
#endif
