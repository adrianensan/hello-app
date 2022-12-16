import SwiftUI

import HelloCore

struct HelloThemeContextChangeModifier: ViewModifier {
  
  @Environment(\.theme) private var theme
  
  var layer: LayerChange
  
  func body(content: Content) -> some View {
    content.environment(\.theme, theme.context(for: layer))
  }
}

public extension View {
  func theme(contextChange: LayerChange) -> some View {
    modifier(HelloThemeContextChangeModifier(layer: contextChange))
  }
}
