import Foundation

public extension HelloColor {
  enum creamsicle {}
}

public extension HelloColor.creamsicle {
  static var orange: HelloColor { HelloColor(r: 0.98, g: 0.65, b: 0.23) }
  static var vanilla: HelloColor { HelloColor(r: 1, g: 1, b: 0.97) }
}
