import Foundation

public extension HelloColor {
  enum google {}
}

public extension HelloColor.google {
  static var red: HelloColor { HelloColor(r: 0.91, g: 0.27, b: 0.21) }
  static var green: HelloColor { HelloColor(r: 0.22, g: 0.68, b: 0.32) }
  static var blue: HelloColor { HelloColor(r: 0.26, g: 0.53, b: 0.96) }
  static var yellow: HelloColor { HelloColor(r: 0.98, g: 0.74, b: 0) }
}
