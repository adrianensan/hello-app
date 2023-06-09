import Foundation

public extension HelloColor {
  enum bluePalette {}
}

public extension HelloColor.bluePalette {
  static var light: HelloColor { HelloColor(r: 0.5, g: 0.8, b: 1) }
  static var medium: HelloColor { HelloColor(r: 0.21, g: 0.47, b: 0.96) }
  static var dark: HelloColor { HelloColor(r: 0.09, g: 0.22, b: 0.46) }
}
