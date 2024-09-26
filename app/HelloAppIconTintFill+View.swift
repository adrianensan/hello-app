import SwiftUI

import HelloCore
import HelloApp

public extension HelloAppIconTintFill {
  @MainActor
  @ViewBuilder
  var view: some View {
    switch self {
    case .color(let color):
      color.swiftuiColor
    case .gradient(let color1, let color2):
      LinearGradient(
        colors: [color1.swiftuiColor, color2.swiftuiColor],
        startPoint: .top,
        endPoint: .bottom)
    case .colorBlock(let colors, let orientation):
      Stack(orientation: orientation) {
        ForEach(colors) { color in
          color.swiftuiColor
        }
      }
    }
  }
}
