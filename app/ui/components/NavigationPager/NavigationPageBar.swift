import SwiftUI

public struct NavigationPageBar<NavBarContent: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.helloPagerConfig) private var config
  
  let title: String?
  @ViewBuilder let navBarContent: @MainActor () -> NavBarContent
  
  var titleHeight: CGFloat {
    config.belowNavBarPadding > 0 ? 44 : config.navBarHeight
  }
  
  public var body: some View {
    ZStack(alignment: .top) {
      if let title {
        NavigationPageTitle(title: title)
          .frame(height: titleHeight)
          .padding(.top, config.belowNavBarPadding)
      }
      navBarContent()
        .frame(height: config.navBarHeight)
    }.font(.system(size: 20, weight: .semibold, design: .rounded))
      .foregroundColor(theme.header.foreground.primary.color)
      .padding(.horizontal, config.horizontalPagePadding)
//      .padding(.top, config.belowNavBarPadding)
      .frame(height: title == nil
             ? max(config.navBarHeight, config.belowNavBarPadding)
             : titleHeight + config.belowNavBarPadding,
             alignment: .top)
  }
}
