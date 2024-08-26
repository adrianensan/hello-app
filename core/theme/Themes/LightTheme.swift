public extension HelloTheme {
  
  static var light: HelloTheme {
    light(accent: .color(color: .retroApple.blue))
  }
  
  static func light(accent: HelloFill) -> HelloTheme {
    HelloTheme(id: "light",
               name: "Light",
               scheme: .light,
               baseLayer: .init(background: .color(color: HelloColor(r: 1, g: 1, b: 1),
                                                   border: .init(color: .black.opacity(0.2))),
                                accent: accent),
               headerLayer: .init(background: .blur(dark: false, overlay: HelloColor(r: 1, g: 1, b: 1).opacity(0.4))))
  }
}
