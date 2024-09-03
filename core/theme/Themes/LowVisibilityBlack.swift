import Foundation

public extension HelloTheme {
  
  static func superBlack(accent: HelloColor) -> HelloTheme {
    let layer = HelloThemeLayerBuilder.init(
      background: .color(color: .black, border: .init(color: .white.opacity(0.1))),
      foregroundPrimary: .color(color: .white.withFakeAlpha(0.35)),
      foregroundSecondary: .color(color: .white.withFakeAlpha(0.3)),
      foregroundTertiary: .color(color: .white.withFakeAlpha(0.25)),
      foregroundQuaternary: .color(color: .white.withFakeAlpha(0.2)),
      accent: .color(color: accent.withFakeAlpha(0.5)),
      error: .color(color: .retroApple.red.withFakeAlpha(0.5))
    )
    return HelloTheme(
      id: "super-black",
      name: "Super Black",
      scheme: .dark,
      baseLayer: layer,
      headerLayer: layer,
      floatingLayer: layer,
      surfaceLayer: layer,
      surfaceSectionLayer: layer)
  }
  
}
