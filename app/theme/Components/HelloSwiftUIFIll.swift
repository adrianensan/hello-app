import SwiftUI

import HelloCore

public extension HelloFill {
  
  var view: AnyShapeStyle {
    switch self {
    case .color(let color): return AnyShapeStyle(color.swiftuiColor)
    case .gradient(let gradient): return AnyShapeStyle(gradient.gradient)
    }
  }
}
