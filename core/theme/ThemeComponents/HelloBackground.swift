import Foundation

public enum HelloBackground: Codable, Sendable, Hashable {
  case color(color: HelloColor, border: HelloBorder? = nil)
  case gradient(HelloGradient)
  case blur(dark: Bool, overlay: HelloColor? = nil, border: HelloBorder? = nil)
  case image(HelloImageBackground)
  
  public var mainColor: HelloColor {
    switch self {
    case .color(let color, _): color
    case .gradient(let gradient): gradient.mainColor
    case .blur(let dark, _, _): dark ? HelloColor(r: 0.1, g: 0.1, b: 0.1) : .white
    case .image: .black
    }
  }
  
  public var borderColor: HelloColor? {
    switch self {
    case .color(_, let borderColor): borderColor?.color
    case .gradient: nil
    case .blur(_, _, let borderColor): borderColor?.color
    case .image: nil
    }
  }
  
  public var borderWidth: CGFloat? {
    switch self {
    case .color(_, let border): border?.width
    case .gradient: nil
    case .blur(_, _, let border): border?.width
    case .image: nil
    }
  }
}
