import Foundation

public extension HelloTheme {
  static var dark: HelloTheme {
    dark(accent: .color(color: .retroApple.blue))
  }
  
  static func dark(accent: HelloFill) -> HelloTheme {
    #if os(macOS)
    HelloTheme(id: "dark",
               name: "Dark",
               scheme: .dark,
               baseLayer: .init(background: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08),
                                                   border: .init(color: .white.opacity(0.1))),
                                accent: accent),
               headerLayer: .init(background: .blur(dark: true, overlay: HelloColor(r: 0.08, g: 0.08, b: 0.08).opacity(0.8))),
               surfaceLayer: .init(background: .color(color: HelloColor(r: 0.14, g: 0.14, b: 0.14),
                                                      border: .init(color: .white.opacity(0.1)))))
    #else
    HelloTheme(id: "dark",
               name: "Dark",
               scheme: .dark,
               baseLayer: .init(background: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08),
                                                   border: .init(color: .white.opacity(0.1))),
                                accent: accent),
               surfaceLayer: .init(background: .color(color: HelloColor(r: 0.14, g: 0.14, b: 0.14),
                                                      border: .init(color: .white.opacity(0.1)))))
    #endif
  }
  
  static var black: HelloTheme {
    black(accent: .color(color: .retroApple.blue))
  }
  
  static func black(accent: HelloFill) -> HelloTheme {
    #if os(macOS)
    HelloTheme(id: "black",
               name: "Black",
               scheme: .dark,
               baseLayer: .init(background: .color(color: HelloColor(r: 0, g: 0, b: 0),
                                                   border: .init(color: .white.opacity(0.1))),
                                accent: accent),
               headerLayer: .init(background: .blur(dark: true, overlay: HelloColor(r: 0, g: 0, b: 0).opacity(0.6))))
    #else
    HelloTheme(id: "black",
               name: "Black",
               scheme: .dark,
               baseLayer: .init(background: .color(color: HelloColor(r: 0, g: 0, b: 0),
                                                   border: .init(color: .white.opacity(0.1))),
                                accent: accent,
                                error: .color(color: .retroApple.red)),
               headerLayer: .init(background: .blur(dark: true, overlay: .black.opacity(0.5))),
               floatingLayer: .init(background: .color(color: HelloColor(r: 0.13, g: 0.12, b: 0.12),
                                                       border: .init(color: .white.opacity(0.1)))),
               surfaceLayer: .init(background: .color(color: HelloColor(r: 0.1, g: 0.09, b: 0.09),
                                                      border: .init(color: .white.opacity(0.1)))))
    #endif
  }
  
  static var systemDark: HelloTheme {
#if os(macOS)
    HelloTheme(id: "black",
               name: "Black",
               scheme: .dark,
               baseLayer: .init(background: .color(color: HelloColor(r: 0, g: 0, b: 0),
                                                   border: .init(color: .white.opacity(0.1))),
                                accent: accent),
               headerLayer: .init(background: .blur(dark: true, overlay: HelloColor(r: 0, g: 0, b: 0).opacity(0.6))))
#else
    HelloTheme(id: "system-dark",
               name: "System Dark",
               scheme: .dark,
               baseLayer: .init(background: .color(color: HelloColor(r: 0, g: 0, b: 0)),
                                foregroundPrimary: .color(color: .white),
                                accent: .color(color: .darkThemeBlueAccent)),
               headerLayer: .init(background: .blur(dark: true)),
               floatingLayer: .init(background: .blur(dark: true)),
               surfaceLayer: .init(background: .color(color: HelloColor(r: 0.11, g: 0.11, b: 0.12))),
               surfaceSectionLayer: .init(background: .color(color: HelloColor(r: 0.2, g: 0.2, b: 0.21))))
#endif
  }
}
