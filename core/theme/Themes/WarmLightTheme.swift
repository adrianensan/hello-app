public extension HelloTheme {
  
  static var warmLight: HelloTheme {
    warmLight(accent: nil)
  }
  
  static func warmLight(accent: HelloFill?) -> HelloTheme {
    HelloTheme(id: "warm-light",
               name: "Warm Light",
               scheme: .light,
               baseLayer: .init(background: .color(color: HelloColor(r: 0.95, g: 0.95, b: 0.93),
                                                   border: .init(color: .black.opacity(0.1))),
                                accent: accent ?? .color(color: .retroApple.blue),
                                error: .color(color: .retroApple.red)),
               headerLayer: .init(background: .blur(dark: false, overlay: .white.opacity(0.4))),
               floatingLayer: .init(background: .color(color: HelloColor(r: 0.98, g: 0.98, b: 0.96),
                                                       border: .init(color: .black.opacity(0.1)))),
               surfaceLayer: .init(background: .color(color: HelloColor(r: 0.93, g: 0.93, b: 0.91),
                                                      border: .init(color: .black.opacity(0.1)))),
               surfaceSectionLayer: .init(background: .color(color: HelloColor(r: 0.97, g: 0.97, b: 0.95),
                                                             border: .init(color: .black.opacity(0.1)))))
  }
}
