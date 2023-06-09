import Foundation

public extension HelloColor {
  enum mario {}
}

public extension HelloColor.mario {
  static var questionBlock: HelloColor { HelloColor(r: 0.95, g: 0.65, b: 0.4) }
  static var questionBlockFill: HelloColor { HelloColor(r: 0.84, g: 0.40, b: 0.2) }
  static var red: HelloColor { HelloColor(r: 0.8, g: 0.2, b: 0.13) }
  static var blue: HelloColor { HelloColor(r: 0.17, g: 0.40, b: 0.88) }
  static var yellow: HelloColor { HelloColor(r: 0.9, g: 0.9, b: 0) }
  static var brick: HelloColor { HelloColor(r: 0.57, g: 0.31, b: 0.13) }
}
