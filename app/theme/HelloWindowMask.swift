#if os(macOS)
import SwiftUI

struct HelloWindowMaskViewModifier<ShapeType: InsettableShape>: ViewModifier {
  
  @Environment(\.theme) private var helloTheme
  
  var shape: ShapeType

  func body(content: Content) -> some View {
    content
      .clipShape(shape)
      .overlay(helloTheme.theme.isDark ? shape.strokeBorder(Color.white.opacity(0.12), lineWidth: 1) : nil)
  }
}

public extension View {
  func helloWindowMask(_ shape: some InsettableShape) -> some View {
    modifier(HelloWindowMaskViewModifier(shape: shape))
  }
}
#endif
