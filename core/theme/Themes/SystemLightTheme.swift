import Foundation

public extension HelloTheme {
  static var systemLight: HelloTheme {
    HelloTheme(
      id: "system-light",
      name: "System Light",
      scheme: .light,
      baseLayer: .init(
        background: .color(color: HelloColor(r: 0.95, g: 0.95, b: 0.96)),
        font: .normal,
        accent: .color(color: .lightThemeBlueAccent)
      ),
      headerLayer: .init(
        background: .blur(dark: false)
      ),
      floatingLayer: .init(
        background: .blur(dark: false)
      ),
      surfaceLayer: .init(
        background: .color(color: HelloColor(r: 1, g: 1, b: 1))
      ),
      surfaceSectionLayer: .init(
        background: .color(color: HelloColor(r: 0.95, g: 0.95, b: 0.95))
      ))
  }
}
