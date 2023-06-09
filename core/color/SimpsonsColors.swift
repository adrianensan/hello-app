import Foundation

public extension HelloColor {
  enum simpsons {}
}

public extension HelloColor.simpsons {
  static var skin: HelloColor { HelloColor(r: 0.99, g: 0.92, b: 0.31) }
  static var eyes: HelloColor { HelloColor.white }
  
  static var margeDress: HelloColor { HelloColor(r: 0.47, g: 0.84, b: 0.45) }
  static var margeHair: HelloColor { HelloColor(r: 0.21, g: 0.47, b: 0.96) }
}
