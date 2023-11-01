import Foundation

public enum HelloSemanticColor: Codable, Sendable {
  case accent
  case error
}

public enum HelloFill: Codable, Sendable {
  case color(color: HelloColor)
  case gradient(HelloGradient)
  case semanticColor(HelloSemanticColor)
  
  public var mainColor: HelloColor {
    switch self {
    case .color(let color): return color
    case .gradient(let gradient): return gradient.mainColor
    case .semanticColor(.accent): return .skyBlue
    case .semanticColor(.error): return .fullRed
    }
  }
}
