import Foundation

public enum HelloFill: Codable {
  case color(color: HelloColor)
  case gradient(HelloGradient)
  
  public var mainColor: HelloColor {
    switch self {
    case .color(let color): return color
    case .gradient(let gradient): return gradient.mainColor
    }
  }
}
