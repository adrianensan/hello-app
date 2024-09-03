public extension HelloTheme {
  
  static var light: HelloTheme {
    light(accent: .color(color: .retroApple.blue))
  }
  
  static func light(accent: HelloFill) -> HelloTheme {
    let layer = HelloThemeLayerBuilder.init(
      background: .color(color: .white, border: .init(color: .black.opacity(0.25))),
      accent: accent,
      error: .color(color: .retroApple.red)
    )
    return HelloTheme(
      id: "monotone-light",
      name: "Monotone Light",
      scheme: .light,
      baseLayer: layer,
      headerLayer: layer,
      floatingLayer: layer,
      surfaceLayer: layer,
      surfaceSectionLayer: layer)
  }
}
