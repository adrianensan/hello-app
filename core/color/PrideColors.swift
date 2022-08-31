import Foundation

public extension HelloColor {
  enum pride {}
}

public extension HelloColor.pride {
  static var red: HelloColor { HelloColor(r: 0.92, g: 0.3, b: 0.24) }
  static var orange: HelloColor { HelloColor(r: 0.95, g: 0.6, b: 0.22) }
  static var yellow: HelloColor { HelloColor(r: 0.97, g: 0.8, b: 0.27) }
  static var green: HelloColor { HelloColor(r: 0.47, g: 0.84, b: 0.45) }
  static var blue: HelloColor { HelloColor(r: 0.21, g: 0.47, b: 0.96) }
  static var violet: HelloColor { HelloColor(r: 0.44, g: 0.2, b: 0.96) }
  static var pink: HelloColor { HelloColor(r: 0.74, g: 0.2, b: 1, a: 1) }
  
  static var all: [HelloColor] {
    [.pride.red, .pride.orange, .pride.yellow,
     .pride.green, .pride.blue, .pride.violet]
  }
}
