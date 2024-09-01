import Foundation

public extension HelloTheme {
  static var pandaDark: HelloTheme {
    pandaDark(accent: .color(color: .retroApple.blue))
  }
  
  static func pandaDark(accent: HelloFill) -> HelloTheme {
    HelloTheme(
      id: "dark",
      name: "Dark",
      scheme: .dark,
      baseLayer: .init(
        background: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08),
                           border: .init(color: HelloColor(r: 0.96, g: 0.96, b: 0.96), width: 2)),
        foregroundPrimary: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.95)),
        accent: accent
      ),
      headerLayer: .init(
        background: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08),
                           border: .init(color: HelloColor(r: 0.96, g: 0.96, b: 0.96), width: 2)),
        foregroundPrimary: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.95))
      ),
      floatingLayer: .init(
        background: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08),
                           border: .init(color: HelloColor(r: 0.96, g: 0.96, b: 0.96), width: 2)),
        foregroundPrimary: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.95))
      ),
      surfaceLayer: .init(
        background: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08),
                           border: .init(color: HelloColor(r: 0.96, g: 0.96, b: 0.96), width: 2)),
        foregroundPrimary: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.95))
      ),
      surfaceSectionLayer: .init(
        background: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08),
                           border: .init(color: HelloColor(r: 0.96, g: 0.96, b: 0.96), width: 2)),
        foregroundPrimary: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.95))
      )
    )
  }
  
  static func deepDark(accent: HelloFill) -> HelloTheme {
    HelloTheme(
      id: "dark",
      name: "Dark",
      scheme: .dark,
      baseLayer: .init(
        background: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.95),
                           border: .init(color: HelloColor(r: 0.08, g: 0.08, b: 0.08), width: 2)),
        foregroundPrimary: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08)),
        accent: accent
      ),
      headerLayer: .init(
        background: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.95),
                           border: .init(color: HelloColor(r: 0.08, g: 0.08, b: 0.08), width: 2)),
        foregroundPrimary: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08))
      ),
      floatingLayer: .init(
        background: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.95),
                           border: .init(color: HelloColor(r: 0.08, g: 0.08, b: 0.08), width: 2)),
        foregroundPrimary: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08))
      ),
      surfaceLayer: .init(
        background: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.95),
                           border: .init(color: HelloColor(r: 0.08, g: 0.08, b: 0.08), width: 2)),
        foregroundPrimary: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08))
      ),
      surfaceSectionLayer: .init(
        background: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.95),
                           border: .init(color: HelloColor(r: 0.08, g: 0.08, b: 0.08), width: 2)),
        foregroundPrimary: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08))
      )
    )
  }
  
  static func pandaLight(accent: HelloFill) -> HelloTheme {
    HelloTheme(
      id: "dark",
      name: "Dark",
      scheme: .dark,
      baseLayer: .init(
        background: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08),
                           border: .init(color: HelloColor(r: 0.96, g: 0.96, b: 0.96), width: 2)),
        foregroundPrimary: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.95)),
        accent: accent
      ),
      headerLayer: .init(
        background: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08),
                           border: .init(color: HelloColor(r: 0.96, g: 0.96, b: 0.96), width: 2)),
        foregroundPrimary: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.95))
      ),
      floatingLayer: .init(
        background: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.95),
                           border: .init(color: HelloColor(r: 0.08, g: 0.08, b: 0.08), width: 2)),
        foregroundPrimary: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08))
      ),
      surfaceLayer: .init(
        background: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.95),
                           border: .init(color: HelloColor(r: 0.08, g: 0.08, b: 0.08), width: 2)),
        foregroundPrimary: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08))
      ),
      surfaceSectionLayer: .init(
        background: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08),
                           border: .init(color: HelloColor(r: 0.96, g: 0.96, b: 0.96), width: 2)),
        foregroundPrimary: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.95))
      )
    )
  }
}
