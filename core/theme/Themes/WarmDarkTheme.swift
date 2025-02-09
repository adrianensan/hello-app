import Foundation

public extension HelloTheme {
  static var warmDark: HelloTheme {
    warmDark(accent: .color(color: .retroApple.blue))
  }
  
  static func warmDark(accent: HelloFill) -> HelloTheme {
    HelloTheme(
      id: "warm-dark",
      name: "Warm Dark",
      scheme: .dark,
      baseLayer: .init(
        background: .color(color: HelloColor(r: 0.12, g: 0.12, b: 0.11),
                           border: .init(color: .white.opacity(0.08))),
        accent: accent,
        error: .color(color: .retroApple.red)),
      headerLayer: .init(
        background: .blur(dark: true, overlay: .black.opacity(0.5))),
      floatingLayer: .init(
        background: .blur(dark: false,
                          overlay: HelloColor(r: 0.14, g: 0.14, b: 0.13).opacity(0.2),
                          border: .init(color: .white.opacity(0.08)))),
      surfaceLayer: .init(
        background: .color(color: HelloColor(r: 0.14, g: 0.14, b: 0.13),
                           border: .init(color: .white.opacity(0.08)))),
      surfaceSectionLayer: .init(
        background: .color(color: HelloColor(r: 0.18, g: 0.18, b: 0.17),
                           border: .init(color: .white.opacity(0.08))))
    )
  }
}
