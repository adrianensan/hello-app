public extension HelloTheme {
  static var light: HelloTheme {
    HelloTheme(id: "light",
               name: "Light",
               scheme: .light,
               baseLayer: .init(background: .color(color: HelloColor(r: 0.98, g: 0.98, b: 0.98),
                                                   border: .init(color: .black.opacity(0.2)))))
  }
  
  static var warmLight: HelloTheme {
    HelloTheme(id: "warm-light",
               name: "Warm Light",
               scheme: .light,
               baseLayer: .init(background: .color(color: HelloColor(r: 0.98, g: 0.98, b: 0.97),
                                                   border: .init(color: .black.opacity(0.2)))),
               floatingLayer: .init(background: .color(color: HelloColor(r: 1, g: 1, b: 1),
                                                       border: .init(color: .black.opacity(0.1)))),
               surfaceLayer: .init(background: .color(color: HelloColor(r: 1, g: 1, b: 1),
                                                      border: .init(color: .black.opacity(0.1)))))
  }
}
