import Foundation

public extension HelloColor {
  enum forest {}
}

public extension HelloColor.forest {
  static var green1: HelloColor { HelloColor(r: 0.16, g: 0.31, b: 0.24) }
  static var green2: HelloColor { HelloColor(r: 0.21, g: 0.38, b: 0.24) }
  static var green3: HelloColor { HelloColor(r: 0.35, g: 0.55, b: 0.29) }
  static var green4: HelloColor { HelloColor(r: 0.58, g: 0.75, b: 0.42) }
}
