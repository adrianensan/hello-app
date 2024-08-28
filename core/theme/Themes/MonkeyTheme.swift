import Foundation

public extension HelloTheme {
  
  static var monki: HelloTheme {
    HelloTheme(
      id: "monki",
      name: "Monki",
      scheme: .light,
      baseLayer: .init(
        background: .color(color: .monkey.lightOrange),
        foregroundPrimary: .color(color: .monkey.white),
        accent: .color(color: .monkey.darkOrange)
      ),
      headerLayer: .init(
        background: .blur(dark: false, overlay: .monkey.lightOrange.opacity(0.8)),
        foregroundPrimary: .color(color: .monkey.white)
      ),
      floatingLayer: .init(
        background: .color(color: .monkey.lightOrange),
        foregroundPrimary: .color(color: .monkey.white)
      ),
      surfaceLayer: .init(
        background: .color(color: .monkey.white),
        foregroundPrimary: .color(color: .monkey.darkOrange)
      ),
      surfaceSectionLayer: .init(
        background: .color(color: .monkey.lightOrange),
        foregroundPrimary: .color(color: .monkey.white)
      ))
  }
}
