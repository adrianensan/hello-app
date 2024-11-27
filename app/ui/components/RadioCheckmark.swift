import SwiftUI

public struct RadioCheckmark: View {
  
  @Environment(\.theme) private var theme
  
  var isSelected: Bool
  
  public init(isSelected: Bool) {
    self.isSelected = isSelected
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        Circle()
          .strokeBorder(theme.surface.foreground.primary.style.opacity(0.4), lineWidth: 2)
          .scaleEffect(isSelected ? 0.9 : 1)
          .padding(geometry.size.minSide / 20)
        Image(systemName: "checkmark")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .font(.system(size: 17, weight: .bold))
          .foregroundStyle(.white)
          .padding(geometry.size.minSide / 4)
          .frame(width: geometry.size.minSide, height: geometry.size.minSide)
          .background(Circle().fill(theme.surface.accent.style))
          .scaleEffect(isSelected ? 1 : 0.02)
          .opacity(isSelected ? 1 : 0)
      }.animation(.fastSpring, value: isSelected)
        .frame(width: geometry.size.minSide, height: geometry.size.minSide)
        .frame(width: geometry.size.width, height: geometry.size.height)
    }.frame(maxWidth: 32, maxHeight: 32)
  }
}
