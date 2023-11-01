import SwiftUI

import HelloCore

public extension HelloFont {
  
  public func font(size: CGFloat, weight: Font.Weight) -> Font {
    switch self {
    case .rounded: return .system(size: size, weight: weight, design: .rounded)
    case .normal: return .system(size: size, weight: weight, design: .rounded)
    case .mono: return .system(size: size, weight: weight, design: .monospaced)
    case .custom(let fontName): return .custom(fontName, size: size)
    }
  }
  
  public var title: Font {
    font(size: 24, weight: .semibold)
  }
  
  public var sectionTtile: Font {
    font(size: 16, weight: .bold)
  }
  
  public var controlLabel: Font {
    font(size: 12, weight: .semibold)
  }
}
