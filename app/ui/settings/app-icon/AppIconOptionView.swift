import SwiftUI

import HelloCore
import HelloApp

public struct AppIconOptionView<AppIcon: IOSAppIcon>: View {
  
  @Environment(\.theme) private var theme
  
  var icon: AppIcon
  var isSelected: Bool
  var showLabel: Bool = true
  
  public var body: some View {
    VStack(spacing: 4) {
      AppIconView(icon: icon)
        .padding(4)
        .background {
          AppIconShape()
            .stroke(theme.surface.accent.style, lineWidth: 3)
            .opacity(isSelected ? 1 : 0)
        }
      
      if showLabel {
        Text(icon.displayName)
          .font(.system(size: 11, weight: .medium, design: .rounded))
          .foregroundColor(isSelected ? .white : theme.surface.foreground.primary.color)
          .fixedSize()
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background {
            Capsule(style: .continuous)
              .fill(theme.surface.accent.style)
              .opacity(isSelected ? 1 : 0)
          }
      }
    }.frame(width: 76)
      .animation(.easeInOut(duration: 0.2), value: isSelected)
  }
}
