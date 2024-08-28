import Foundation

public extension HelloTheme {
  
  static func superBlack(accent: HelloColor) -> HelloTheme {
    HelloTheme(
      id: "super-black",
      name: "Super Black",
      scheme: .dark,
      baseLayer: .init(
        background: .color(color: HelloColor(r: 0, g: 0, b: 0),
                           border: .init(color: .white.opacity(0.1))),
        foregroundPrimary: .color(color: .white.withFakeAlpha(0.35)),
        accent: .color(color: accent.withFakeAlpha(0.5)),
        error: .color(color: .retroApple.red.withFakeAlpha(0.5))
      ),
      headerLayer: .init(
        background: .blur(dark: true, overlay: .black.opacity(0.6))
      ),
      floatingLayer: .init(
        background: .color(color: HelloColor(r: 0, g: 0, b: 0), border: .init(color: .white.opacity(0.1)))
      ),
      surfaceLayer: .init(
        background: .color(color: HelloColor(r: 0, g: 0, b: 0), border: .init(color: .white.opacity(0.1)))
      ))
  }
  
}
