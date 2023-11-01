import Foundation

public extension HelloTheme {
  
  @available(iOS, unavailable)
  static var lightBlur: HelloTheme {
    HelloTheme(id: "light-blur",
               name: "Light Blur",
               scheme: .light,
               baseLayer: .init(background: .blur(dark: false,
                                                  overlay: HelloColor(r: 1, g: 1, b: 1, a: 0.7),
                                                  border: .init(color: .black.opacity(0.1)))))
  }
}
