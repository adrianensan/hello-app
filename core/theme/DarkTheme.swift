import Foundation

public extension HelloTheme {
  static var dark: HelloTheme {
    HelloTheme(id: "dark", name: "Dark",
               baseLayer: .init(background: .color(color: HelloColor(r: 0.1, g: 0.1, b: 0.1),
                                                   border: .init(color: .white.opacity(0.3)))))
  }
  
  static var light: HelloTheme {
    HelloTheme(id: "light", name: "Light",
               baseLayer: .init(background: .color(color: HelloColor(r: 0.98, g: 0.98, b: 0.98),
                                                   border: .init(color: .black.opacity(0.2)))))
  }
}


//public extension HelloThemeBuildable where Self == DarkTheme {
//  static var dark: DarkTheme { DarkTheme() }
//}
