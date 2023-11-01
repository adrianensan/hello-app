import Foundation

public protocol HelloThemeSet {
  var lightTheme: HelloTheme { get }
  var darkTheme: HelloTheme { get }
}

public struct HelloSynamicTheme {
  var light: HelloTheme
  var dark: HelloTheme
  
  public init(light: HelloTheme, dark: HelloTheme) {
    self.light = light
    self.dark = dark
  }
}
