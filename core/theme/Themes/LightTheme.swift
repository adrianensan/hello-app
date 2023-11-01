public extension HelloTheme {
  static var light: HelloTheme {
    HelloTheme(id: "light",
               name: "Light",
               scheme: .light,
               baseLayer: .init(background: .color(color: HelloColor(r: 0.98, g: 0.98, b: 0.98),
                                                   border: .init(color: .black.opacity(0.2)))))
  }
}
