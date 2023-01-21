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
      ZStack {
        shape.fill((overlay ?? .transparent).swiftuiColor)
          .background(BehindWindowBlur(material: .fullScreenUI, isBaseLayer: isBaseLayer))
          .clipShape(shape)
      
        if !isBaseLayer, let border {
          shape.stroke(border.color.swiftuiColor, lineWidth: border.width)
        }
      }
      #elseif os(iOS)
      if !isBaseLayer, let border {
        shape.fill((overlay ?? .transparent).swiftuiColor)
          .background(.ultraThinMaterial)
          .border(border.color.swiftuiColor, width: border.width)
      } else {
        shape.fill((overlay ?? .transparent).swiftuiColor)
          .background(.ultraThinMaterial)
      }
      #else
      if !isBaseLayer, let border {
        shape.fill((overlay ?? .transparent).swiftuiColor)
          .border(border.color.swiftuiColor, width: border.width)
      } else {
        shape.fill((overlay ?? .transparent).swiftuiColor)
      }
      #endif
    case .image(let image):
      switch image.mode {
      case .fill:
        Image(image.name)
          .resizable()
          .aspectRatio(contentMode: .fill)
      case .fillLengthwise:
        GeometryReader { geometry in
          if geometry.size.width > geometry.size.height {
            Image(image.name)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: geometry.size.width, height: geometry.size.height)
          } else {
            Image(image.name)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: geometry.size.height, height: geometry.size.width)
              .rotationEffect(.radians(0.5 * .pi))
              .frame(width: geometry.size.width, height: geometry.size.height)
          }
        }
      case .tile:
        Image(image.name)
          .resizable(capInsets: .init(), resizingMode: .tile)
          .aspectRatio(contentMode: .fill)
      }
    }
  }
}
