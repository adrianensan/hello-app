import Foundation

public extension HelloTheme {
  static var dark: HelloTheme {
    HelloTheme(id: "dark",
               name: "Dark",
               scheme: .dark,
               baseLayer: .init(background: .color(color: HelloColor(r: 0.08, g: 0.08, b: 0.08),
                                                   border: .init(color: .white.opacity(0.1)))),
               surfaceLayer: .init(background: .color(color: HelloColor(r: 0.14, g: 0.14, b: 0.14),
                                                   border: .init(color: .white.opacity(0.1)))))
  }
  
  static var black: HelloTheme {
    HelloTheme(id: "black",
               name: "Black",
               scheme: .dark,
               baseLayer: .init(background: .color(color: HelloColor(r: 0, g: 0, b: 0),
                                                   border: .init(color: .white.opacity(0.1)))))
  }
}
