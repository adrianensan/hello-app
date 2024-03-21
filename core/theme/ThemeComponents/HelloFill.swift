import Foundation

public enum HelloSemanticColor: Codable, Sendable, Hashable {
  case accent
  case error
}

public enum HelloFill: Codable, Sendable, Hashable {
  case color(color: HelloColor)
  case gradient(HelloGradient)
  case semanticColor(HelloSemanticColor)
  
  public var mainColor: HelloColor {
    switch self {
    case .color(let color): return color
    case .gradient(let gradient): return gradient.mainColor
    case .semanticColor(.accent): return HelloColor(r: 0.5, g: 0.6, b: 0.96)
    case .semanticColor(.error): return .fullRed
    }
  }
}
