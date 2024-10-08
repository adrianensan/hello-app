import SwiftUI

public struct NavigationPageBar<TitleContent: View, NavBarContent: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.helloPagerConfig) private var config
  
  @ViewBuilder let titleContent: @MainActor () -> TitleContent
  @ViewBuilder let navBarContent: @MainActor () -> NavBarContent
  
  var titleHeight: CGFloat {
//    config.belowNavBarPadding > 0 ? 44 : config.navBarHeight
    config.navBarHeight
  }
  
  public var body: some View {
    ZStack(alignment: .top) {
      titleContent()
        .frame(height: titleHeight)
        .padding(.top, config.belowNavBarPadding)
      navBarContent()
        .frame(height: config.navBarHeight)
    }.font(.system(size: 20, weight: .semibold))
      .foregroundColor(theme.header.foreground.primary.color)
//      .padding(.top, config.belowNavBarPadding)
//      .frame(height: title == nil
//             ? max(config.navBarHeight, config.belowNavBarPadding)
//             : titleHeight + config.belowNavBarPadding,
//             alignment: .top)
  }
}
