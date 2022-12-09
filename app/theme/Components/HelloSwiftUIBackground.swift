import SwiftUI

import HelloCore

public extension HelloBackground {
  
  @ViewBuilder
  func view(for shape: some Shape) -> some View {
    switch self {
    case .color(let color, let border):
      if let border {
        shape.fill(color.swiftuiColor)
          .border(border.color.swiftuiColor, width: border.width)
      } else {
        shape.fill(color.swiftuiColor)
      }
    case .gradient(let gradient):
      shape.fill(gradient.gradient)
    case .blur(_, let overlay, let border):
      if let border {
        (overlay ?? .transparent).swiftuiColor
          .background(.ultraThinMaterial)
          .border(border.color.swiftuiColor, width: border.width)
      } else {
        (overlay ?? .transparent).swiftuiColor
          .background(.ultraThinMaterial)
      }
    case .image(let image):
      switch image.mode {
      case .fill:
        Image(image.name)
          .resizable()
          .aspectRatio(contentMode: .fill)
      case .tile:
        Image(image.name)
          .resizable(capInsets: .init(), resizingMode: .tile)
          .aspectRatio(contentMode: .fill)
      }
    case .windowBlur:
      #if os(macOS)
      BehindWindowBlur(material: .sidebar, blendingMode: .behindWindow)
      #else
      Color.clear
      #endif
    }
  }
}
