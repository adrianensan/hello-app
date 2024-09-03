import Foundation

public extension HelloColor {
  enum retroGrey {}
}

public extension HelloColor.retroGrey {
  static var light: HelloColor { HelloColor(r: 1, g: 1, b: 1) }
  static var medium: HelloColor { HelloColor(r: 0.74, g: 0.74, b: 0.74) }
  static var dark: HelloColor { HelloColor(r: 0.48, g: 0.48, b: 0.48) }
}
