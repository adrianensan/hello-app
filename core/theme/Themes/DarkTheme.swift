import Foundation

public extension HelloTheme {
  static var dark: HelloTheme {
    HelloTheme(id: "dark", name: "Dark",
               baseLayer: .init(background: .color(color: HelloColor(r: 0.1, g: 0.1, b: 0.1),
                                                   border: .init(color: .white.opacity(0.3)))))
  }
}
