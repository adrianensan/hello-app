import Foundation

public extension HelloTheme {
  static var systemDark: HelloTheme {
    HelloTheme(id: "system-dark",
               name: "System Dark",
               scheme: .dark,
               baseLayer: .init(background: .color(color: HelloColor(r: 0, g: 0, b: 0)),
                                foregroundPrimary: .color(color: .white),
                                font: .normal,
                                accent: .color(color: .darkThemeBlueAccent)),
               headerLayer: .init(background: .blur(dark: true)),
               floatingLayer: .init(background: .blur(dark: true)),
               surfaceLayer: .init(background: .color(color: HelloColor(r: 0.11, g: 0.11, b: 0.12))),
               surfaceSectionLayer: .init(background: .color(color: HelloColor(r: 0.2, g: 0.2, b: 0.21))))
  }
}
