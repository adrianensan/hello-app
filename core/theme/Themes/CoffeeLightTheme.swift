import Foundation

public extension HelloTheme {
  
  static var coffeeLight: HelloTheme {
    HelloTheme(
      id: "coffee-light",
      name: "Coffee Light",
      scheme: .light,
      baseLayer: .init(
        background: .color(color: .coffee.light),
        foregroundPrimary: .color(color: .coffee.dark),
        accent: .color(color: .coffee.accent)
      ),
      headerLayer: .init(
        background: .blur(dark: true, overlay: .coffee.light.opacity(0.8)),
        foregroundPrimary: .color(color: .coffee.dark)
      ),
      floatingLayer: .init(
        background: .color(color: .coffee.mediumLight),
        foregroundPrimary: .color(color: .coffee.dark)
      ),
      surfaceLayer: .init(
        background: .color(color: .coffee.mediumLight),
        foregroundPrimary: .color(color: .coffee.dark)
      ),
      surfaceSectionLayer: .init(
        background: .color(color: .coffee.medium),
        foregroundPrimary: .color(color: .coffee.light)
      ))
  }
}
