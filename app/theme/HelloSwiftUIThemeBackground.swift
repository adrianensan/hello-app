import SwiftUI

struct HelloBackgroundViewModifier: ViewModifier {
  
  @Environment(\.theme) private var theme
  
  var shape: AnyInsettableShape
  var layer: HelloSwiftUITheme.HelloSwiftUIThemeLayerID
  
  func body(content: Content) -> some View {
    content
      .clipShape(shape)
      .background(theme.layer(layer).backgroundView(for: shape))
      .environment(\.contentShape, shape)
  }
}

@MainActor
public extension View {
  func helloBackground(shape: some InsettableShape, layer: HelloSwiftUITheme.HelloSwiftUIThemeLayerID = .base) -> some View {
    modifier(HelloBackgroundViewModifier(shape: AnyInsettableShape(shape), layer: layer))
  }
  
  func helloBackground(layer: HelloSwiftUITheme.HelloSwiftUIThemeLayerID = .base) -> some View {
    helloBackground(shape: Rectangle(), layer: layer)
  }
}
