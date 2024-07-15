import SwiftUI

import HelloCore

public extension HelloBackground {
  
  @MainActor
  @ViewBuilder
  func view(for shape: some InsettableShape, isBaseLayer: Bool = true) -> some View {
    switch self {
    case .color(let color, let border):
      ZStack {
        shape.fill(color.swiftuiColor)
        if !isBaseLayer, let border {
          shape.strokeBorder(border.color.swiftuiColor, lineWidth: border.width)
        }
      }
    case .gradient(let gradient):
      shape.fill(gradient.gradient)
    case .blur(_, let overlay, let border):
      ZStack {
        #if os(macOS)
        shape.fill((overlay ?? .transparent).swiftuiColor)
          .background(BehindWindowBlur(material: .fullScreenUI, isBaseLayer: isBaseLayer))
          .clipShape(shape)
        if !isBaseLayer, let border {
          shape.strokeBorder(border.color.swiftuiColor, lineWidth: border.width)
        }
        #elseif os(iOS)
        shape.fill((overlay ?? .transparent).swiftuiColor)
          .background(.ultraThinMaterial)
        if !isBaseLayer, let border {
          shape.strokeBorder(border.color.swiftuiColor, lineWidth: border.width)
        }
        #else
        shape.fill((overlay ?? .transparent).swiftuiColor)
        if !isBaseLayer, let border {
          shape.strokeBorder(border.color.swiftuiColor, lineWidth: border.width)
        }
        #endif
      }
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
