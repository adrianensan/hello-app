import Foundation

public extension HelloTheme {
  
  @available(iOS, unavailable)
  static var darkBlur: HelloTheme {
    HelloTheme(id: "dark", name: "Dark",
               baseLayer: .init(background: .windowBlur))
  }
}
