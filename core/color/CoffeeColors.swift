import Foundation

public extension HelloColor {
  enum coffee {}
}

public extension HelloColor.coffee {
  static var light: HelloColor { HelloColor(r: 0.92, g: 0.88, b: 0.83) }
  static var mediumLight: HelloColor { HelloColor(r: 0.84, g: 0.76, b: 0.68) }
  static var medium: HelloColor { HelloColor(r: 0.56, g: 0.45, b: 0.36) }
  static var mediumDark: HelloColor { HelloColor(r: 0.37, g: 0.29, b: 0.21) }
  static var dark: HelloColor { HelloColor(r: 0.21, g: 0.14, b: 0.07) }
  
  static var accent: HelloColor { HelloColor(r: 0.81, g: 0.61, b: 0.39) }
}
