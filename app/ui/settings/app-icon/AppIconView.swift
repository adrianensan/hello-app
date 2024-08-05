import SwiftUI

import HelloApp

public struct AppIconView<AppIcon: IOSAppIcon>: View {
  
  @Environment(\.theme) var theme
  
  var icon: AppIcon
  
  var isSmall: Bool = false
  
  public var body: some View {
    icon.view.flattenedView
      .clipShape(AppIconShape())
      .frame(width: isSmall ? 32 : 60, height: isSmall ? 32 : 60)
      .overlay(AppIconShape().stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
  }
}
