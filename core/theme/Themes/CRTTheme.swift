import Foundation

public extension HelloTheme {
  
  static var crt: HelloTheme {
    let layer = HelloThemeLayerBuilder(
      background: .color(color: .black, border: .init(color: .neonGreen, width: 2)),
      foregroundPrimary: .color(color: .neonGreen),
      foregroundSecondary: .color(color: .neonGreen),
      foregroundTertiary: .color(color: .neonGreen),
      foregroundQuaternary: .color(color: .neonGreen),
      font: .mono,
      accent: .color(color: .neonGreen)
    )
    return HelloTheme(
      id: "crt-dark",
      name: "CRT",
      scheme: .dark,
      baseLayer: layer,
      headerLayer: layer,
      floatingLayer: layer,
      surfaceLayer: layer,
      surfaceSectionLayer: layer)
  }
}
