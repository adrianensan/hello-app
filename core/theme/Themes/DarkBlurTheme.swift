import Foundation

public extension HelloTheme {
  
  static var darkBlur: HelloTheme {
    HelloTheme(id: "dark-blur",
               name: "Dark Blur",
               scheme: .dark,
               baseLayer: .init(background: .blur(dark: true,
                                                  overlay: HelloColor(r: 0.1, g: 0.1, b: 0.1, a: 0.2),
                                                  border: .init(color: .white.opacity(0.3)))))
  }
}
