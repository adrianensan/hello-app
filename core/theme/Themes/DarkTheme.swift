import Foundation

public extension HelloTheme {
  static var dark: HelloTheme {
    HelloTheme(id: "dark",
               name: "Dark",
               scheme: .dark,
               baseLayer: .init(background: .color(color: HelloColor(r: 0.1, g: 0.1, b: 0.1),
                                                   border: .init(color: .white.opacity(0.2)))))
  }
  
  static var black: HelloTheme {
    HelloTheme(id: "black",
               name: "Black",
               scheme: .dark,
               baseLayer: .init(background: .color(color: HelloColor(r: 0, g: 0, b: 0),
                                                   border: .init(color: .white.opacity(0.1)))))
  }
}
