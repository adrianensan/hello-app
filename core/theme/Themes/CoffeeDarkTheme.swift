import Foundation

public extension HelloTheme {
  
  static var coffeeDark: HelloTheme {
    HelloTheme(
      id: "coffee-dark",
      name: "Coffee Dark",
      scheme: .dark,
      baseLayer: .init(
        background: .color(color: .coffee.dark),
        foregroundPrimary: .color(color: .coffee.light),
        accent: .color(color: .retroApple.yellow)
      ),
      headerLayer: .init(
        background: .blur(dark: true, overlay: .coffee.dark.opacity(0.8)),
        foregroundPrimary: .color(color: .coffee.light)
      ),
      floatingLayer: .init(
        background: .color(color: .coffee.mediumDark),
        foregroundPrimary: .color(color: .coffee.light)
      ),
      surfaceLayer: .init(
        background: .color(color: .coffee.mediumDark),
        foregroundPrimary: .color(color: .coffee.light)
      ),
      surfaceSectionLayer: .init(
        background: .color(color: .coffee.medium),
        foregroundPrimary: .color(color: .coffee.light)
      ))
  }
}
