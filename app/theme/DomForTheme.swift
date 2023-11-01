import SwiftUI

struct ThemeDimViewModifier: ViewModifier {
  
  @Environment(\.theme) private var helloTheme
  
  func body(content: Content) -> some View {
    if helloTheme.theme.isDim {
      content.overlay(Color.black.opacity(0.6))
    } else {
      content
    }
  }
}

public extension View {
  func dimForTheme() -> some View {
    modifier(ThemeDimViewModifier())
  }
}
