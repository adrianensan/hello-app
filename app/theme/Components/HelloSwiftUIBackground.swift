import SwiftUI

import HelloCore

public extension HelloBackground {
  
  @ViewBuilder
  func view(for shape: some Shape, isBaseLayer: Bool = true) -> some View {
    switch self {
    case .color(let color, let border):
      if !isBaseLayer, let border {
        shape.fill(color.swiftuiColor)
          .border(border.color.swiftuiColor, width: border.width)
      } else {
        shape.fill(color.swiftuiColor)
      }
    case .gradient(let gradient):
      shape.fill(gradient.gradient)
    case .blur(_, let overlay, let border):
      #if os(macOS)
      if !isBaseLayer, let border {
        shape.fill((overlay ?? .transparent).swiftuiColor)
          .background(BehindWindowBlur(material: .fullScreenUI))
          .clipShape(shape)
          .border(border.color.swiftuiColor, width: border.width)
      } else {
        shape.fill((overlay ?? .transparent).swiftuiColor)
          .background(BehindWindowBlur(material: .fullScreenUI))
          .clipShape(shape)
      }
      #else
      if !isBaseLayer, let border {
        shape.fill((overlay ?? .transparent).swiftuiColor)
          .background(.ultraThinMaterial)
          .border(border.color.swiftuiColor, width: border.width)
      } else {
        shape.fill((overlay ?? .transparent).swiftuiColor)
          .background(.ultraThinMaterial)
      }
      #endif
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
    }
  }
}
