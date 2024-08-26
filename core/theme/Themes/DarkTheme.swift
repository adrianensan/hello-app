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
}
