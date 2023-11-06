import Foundation

public struct HelloGradient: Codable, Sendable, Hashable {
  
  public enum GradientType: Codable, Sendable {
    case topToBottom
    case leftToRight
  }
  
  public var colors: [HelloColor]
  public var direction: GradientType
  
  public var mainColor: HelloColor {
    colors.first ?? .transparent
  }
  
  public init(colors: [HelloColor],
              direction: HelloGradient.GradientType) {
    self.colors = colors
    self.direction = direction
  }
}
