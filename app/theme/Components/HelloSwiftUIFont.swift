import SwiftUI

import HelloCore

public extension HelloFont {
  
  func font(size: CGFloat, weight: Font.Weight) -> Font {
    switch self {
    case .rounded: return .system(size: size, weight: weight, design: .rounded)
    case .normal: return .system(size: size, weight: weight, design: .rounded)
    case .mono: return .system(size: size, weight: weight, design: .monospaced)
    case .custom(let fontName): return .custom(fontName, size: size)
    }
  }
  
  var title: Font {
    font(size: 24, weight: .semibold)
  }
  
  var sectionTtile: Font {
    font(size: 16, weight: .bold)
  }
  
  var controlLabel: Font {
    font(size: 12, weight: .semibold)
  }
}
