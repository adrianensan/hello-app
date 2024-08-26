import Foundation

public extension HelloTheme {
  static func monotoneDark(accent: HelloFill) -> HelloTheme {
    let layer = HelloThemeLayerBuilder.init(
      background: .color(color: .black, border: .init(color: .white.opacity(0.25))),
      accent: accent,
      error: .color(color: .retroApple.red)
    )
    return HelloTheme(
      id: "monotone-dark",
      name: "Monotone Dark",
      scheme: .dark,
      baseLayer: layer,
      headerLayer: layer,
      floatingLayer: layer,
      surfaceLayer: layer,
      surfaceSectionLayer: layer)
  }
}
