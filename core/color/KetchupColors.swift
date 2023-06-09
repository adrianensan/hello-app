import Foundation

public extension HelloColor {
  enum ketchup {}
}

public extension HelloColor.ketchup {
  static var red: HelloColor { HelloColor(r: 0.77, g: 0, b: 0) }
  static var yellow: HelloColor { HelloColor(r: 0.96, g: 0.7, b: 0) }
  static var orange: HelloColor { HelloColor(r: 0.9, g: 0.57, b: 0.05) }
}
