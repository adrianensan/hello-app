import Foundation

public extension HelloColor {
  enum monkey {}
}

public extension HelloColor.monkey {
  static var lightOrange: HelloColor { HelloColor(r: 0.71, g: 0.46, b: 0.35) }
  static var darkOrange: HelloColor { HelloColor(r: 0.60, g: 0.36, b: 0.27) }
  static var white: HelloColor { HelloColor(r: 0.95, g: 0.93, b: 0.93) }
}
