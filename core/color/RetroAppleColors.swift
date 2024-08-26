import Foundation

public extension HelloColor {
  enum retroApple {}
}

public extension HelloColor.retroApple {
  static var green: HelloColor { HelloColor(r: 0.47, g: 0.72, b: 0.33, a: 1) }
  static var yellow: HelloColor { HelloColor(r: 0.92, g: 0.71, b: 0.28, a: 1) }
  static var orange: HelloColor { HelloColor(r: 0.89, g: 0.53, b: 0.23, a: 1) }
  static var red: HelloColor { HelloColor(r: 0.81, g: 0.29, b: 0.27, a: 1) }
  static var purple: HelloColor { HelloColor(r: 0.53, g: 0.25, b: 0.56, a: 1) }
  static var blue: HelloColor { HelloColor(r: 0.27, g: 0.61, b: 0.84, a: 1) }
  
  static var lightPlastic: HelloColor { HelloColor(r: 0.86, g: 0.86, b: 0.82) }
  
  static var all: [HelloColor] {
    [.retroApple.green, .retroApple.yellow, .retroApple.orange,
     .retroApple.red, .retroApple.purple, .retroApple.blue]
  }
  
  static var allAccentOptions: [HelloColor] {
    [.retroApple.blue, .retroApple.green, .retroApple.yellow, .retroApple.orange,
     .retroApple.red, .retroApple.purple]
  }
}
