public extension HelloTheme {
  
  static var warmLight: HelloTheme {
    warmLight(accent: .color(color: .retroApple.blue))
  }
  
  static func warmLight(accent: HelloFill) -> HelloTheme {
#if os(macOS)
    HelloTheme(id: "warm-light",
               name: "Warm Light",
               scheme: .light,
               baseLayer: .init(background: .color(color: HelloColor(r: 0.98, g: 0.98, b: 0.97),
                                                   border: .init(color: .black.opacity(0.2))),
                                accent: accent),
               headerLayer: .init(background: .blur(dark: false, overlay: HelloColor(r: 1, g: 1, b: 1).opacity(0.8))),
               floatingLayer: .init(background: .color(color: HelloColor(r: 1, g: 1, b: 1),
                                                       border: .init(color: .black.opacity(0.1)))),
               surfaceLayer: .init(background: .color(color: HelloColor(r: 1, g: 1, b: 1),
                                                      border: .init(color: .black.opacity(0.1)))),
               surfaceSectionLayer: .init(background: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.96),
                                                             border: .init(color: .black.opacity(0.1)))))
#else
    HelloTheme(id: "warm-light",
               name: "Warm Light",
               scheme: .light,
               baseLayer: .init(background: .color(color: HelloColor(r: 0.98, g: 0.98, b: 0.97),
                                                   border: .init(color: .black.opacity(0.2))),
                                accent: accent,
                                error: .color(color: .retroApple.red)),
               headerLayer: .init(background: .blur(dark: false, overlay: .white.opacity(0.4))),
               floatingLayer: .init(background: .color(color: HelloColor(r: 1, g: 1, b: 1),
                                                       border: .init(color: .black.opacity(0.1)))),
               surfaceLayer: .init(background: .color(color: HelloColor(r: 1, g: 1, b: 1),
                                                      border: .init(color: .black.opacity(0.1)))),
               surfaceSectionLayer: .init(background: .color(color: HelloColor(r: 0.96, g: 0.96, b: 0.96),
                                                             border: .init(color: .black.opacity(0.1)))))
#endif
  }
}
