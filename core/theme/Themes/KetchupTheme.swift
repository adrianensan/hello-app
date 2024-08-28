import Foundation

public extension HelloTheme {
  
  static var ketchup: HelloTheme {
    HelloTheme(
      id: "ketchup",
      name: "Ketchup",
      scheme: .dark,
      baseLayer: .init(
        background: .color(color: .ketchup.red),
        foregroundPrimary: .color(color: .ketchup.yellow),
        accent: .color(color: .ketchup.yellow)
      ),
      headerLayer: .init(
        background: .blur(dark: true, overlay: .ketchup.red.opacity(0.8)),
        foregroundPrimary: .color(color: .ketchup.yellow)
      ),
      floatingLayer: .init(
        background: .color(color: .ketchup.orange),
        foregroundPrimary: .color(color: .ketchup.brown)
      ),
      surfaceLayer: .init(
        background: .color(color: .ketchup.orange),
        foregroundPrimary: .color(color: .ketchup.brown)
      ),
      surfaceSectionLayer: .init(
        background: .color(color: .ketchup.red),
        foregroundPrimary: .color(color: .ketchup.yellow)
      ))
  }
}
