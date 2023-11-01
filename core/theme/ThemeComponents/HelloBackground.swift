import Foundation

public enum HelloBackground: Codable, Sendable {
  case color(color: HelloColor, border: HelloBorder? = nil)
  case gradient(HelloGradient)
  case blur(dark: Bool, overlay: HelloColor? = nil, border: HelloBorder? = nil)
  case image(HelloImageBackground)
  
  public var mainColor: HelloColor {
    switch self {
    case .color(let color, _): return color
    case .gradient(let gradient): return gradient.mainColor
    case .blur(let dark, _, _): return dark ? HelloColor(r: 0.1, g: 0.1, b: 0.1) : .white
    case .image: return .black
    }
  }
}
