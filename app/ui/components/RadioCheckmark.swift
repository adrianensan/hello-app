import SwiftUI

import HelloApp

public struct RadioCheckmark: View {
  
  @Environment(\.theme) private var theme
  
  var isSelected: Bool
  var size: CGFloat = 32
  
  public init(isSelected: Bool) {
    self.isSelected = isSelected
  }
  
  public var body: some View {
    ZStack {
      Circle()
        .strokeBorder(theme.surface.foreground.primary.style.opacity(0.4), lineWidth: 2)
        .scaleEffect(isSelected ? 0.9 : 1)
        .padding(size / 20)
      Image(systemName: "checkmark")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .font(.system(size: 17, weight: .bold, design: .rounded))
        .foregroundColor(.white)
        .padding(size / 4)
        .frame(width: size, height: size)
        .background(Circle().fill(theme.surface.accent.style))
        .scaleEffect(isSelected ? 1 : 0.02)
        .opacity(isSelected ? 1 : 0)
    }.animation(.fastSpring, value: isSelected)
      .frame(width: size, height: size)
  }
}
