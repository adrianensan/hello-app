import Foundation

public extension HelloTheme {
  
  static var underwater: HelloTheme {
    HelloTheme(
      id: "underwater",
      name: "Underwater",
      scheme: .dark,
      baseLayer: .init(
        background: .color(color: .underwater.dark),
        foregroundPrimary: .color(color: .underwater.light),
        accent: .color(color: .retroApple.yellow)
      ),
      headerLayer: .init(
        background: .blur(dark: true, overlay: .underwater.dark.opacity(0.8)),
        foregroundPrimary: .color(color: .underwater.light)
      ),
      floatingLayer: .init(
        background: .color(color: .underwater.mediumDark),
        foregroundPrimary: .color(color: .underwater.light)
      ),
      surfaceLayer: .init(
        background: .color(color: .underwater.mediumDark),
        foregroundPrimary: .color(color: .underwater.light)
      ),
      surfaceSectionLayer: .init(
        background: .color(color: .underwater.medium),
        foregroundPrimary: .color(color: .underwater.light)
      ))
  }
}
