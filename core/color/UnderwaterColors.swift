import Foundation

public extension HelloColor {
  enum underwater {}
}

public extension HelloColor.underwater {
  static var dark: HelloColor { HelloColor(r: 0.24, g: 0.2, b: 0.91) }
  static var mediumDark: HelloColor { HelloColor(r: 0.2, g: 0.38, b: 0.86) }
  static var medium: HelloColor { HelloColor(r: 0.31, g: 0.68, b: 0.97) }
  static var mediumLight: HelloColor { HelloColor(r: 0.42, g: 0.9, b: 0.99) }
  static var light: HelloColor { HelloColor(r: 0.81, g: 0.96, b: 0.95) }
}
