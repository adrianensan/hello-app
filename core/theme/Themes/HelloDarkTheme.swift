import Foundation

public extension HelloTheme {
  static var helloDark: HelloTheme {
    helloDark(accent: .color(color: .retroApple.blue))
  }
  
  static func helloDark(accent: HelloFill) -> HelloTheme {
#if os(macOS)
    HelloTheme(id: "black",
               name: "Black",
               scheme: .dark,
               baseLayer: .init(background: .color(color: HelloColor(r: 0, g: 0, b: 0),
                                                   border: .init(color: .white.opacity(0.1))),
                                accent: accent),
               headerLayer: .init(background: .blur(dark: true, overlay: HelloColor(r: 0, g: 0, b: 0).opacity(0.6))))
#else
    HelloTheme(
      id: "black",
      name: "Black",
      scheme: .dark,
      baseLayer: .init(
        background: .color(color: HelloColor(r: 0, g: 0, b: 0),
                           border: .init(color: .white.opacity(0.12))),
        accent: accent,
        error: .color(color: .retroApple.red)),
      headerLayer: .init(
        background: .blur(dark: true, overlay: .black.opacity(0.5))),
      floatingLayer: .init(
        background: .color(color: HelloColor(r: 0.12, g: 0.12, b: 0.11),
                           border: .init(color: .white.opacity(0.1)))),
      surfaceLayer: .init(
        background: .color(color: HelloColor(r: 0.09, g: 0.09, b: 0.08),
                           border: .init(color: .white.opacity(0.1)))),
      surfaceSectionLayer: .init(
        background: .color(color: HelloColor(r: 0.16, g: 0.16, b: 0.15),
                           border: .init(color: .white.opacity(0.1))))
    )
#endif
  }
}
