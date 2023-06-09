import Foundation

public extension HelloColor {
  enum lego {}
}

public extension HelloColor.lego {
  static var red: HelloColor { HelloColor(r: 0.65, g: 0.13, b: 0.09) }
  static var blue: HelloColor { HelloColor(r: 0.19, g: 0.35, b: 0.64) }
  static var yellow: HelloColor { HelloColor(r: 0.95, g: 0.79, b: 0.27) }
  static var orange: HelloColor { HelloColor(r: 0.79, g: 0.49, b: 0.22) }
  static var green: HelloColor { HelloColor(r: 0.43, g: 0.66, b: 0.31) }
}
