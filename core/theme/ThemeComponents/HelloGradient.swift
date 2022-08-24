import Foundation

public struct HelloGradient: Codable {
  
  public enum GradientType: Codable {
    case topToBottom
    case leftToRight
  }
  
  public var colors: [HelloColor]
  public var direction: GradientType
  
  public var mainColor: HelloColor {
    colors.first ?? .transparent
  }
}
