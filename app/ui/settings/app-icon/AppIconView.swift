import SwiftUI

import HelloCore

public struct AppIconView<AppIcon: BaseAppIcon>: View {
  
  @Environment(\.theme) var theme
  
  var icon: AppIcon
  
  var isSmall: Bool = false
  
  public var body: some View {
    HelloImageView(.asset(named: icon.imageName))
//    icon.view.flattenedView
      .clipShape(AppIconShape())
      .overlay(AppIconShape().stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
  }
}
