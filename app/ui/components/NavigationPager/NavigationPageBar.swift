#if os(iOS)
import SwiftUI

@MainActor
public struct NavigationPageBar<NavBarContent: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.helloPagerConfig) private var config
  @Environment(HelloScrollModel.self) private var scrollModel
  
  let title: String?
  let navBarContent: () -> NavBarContent
  
  var titleHeight: CGFloat {
    config.belowNavBarPadding > 0 ? 44 : config.defaultNavBarHeight
  }
  
  public var body: some View {
    ZStack(alignment: .top) {
      if let title {
        NavigationPageTitle(title: title)
          .environment(scrollModel)
          .frame(height: titleHeight)
          .padding(.top, config.belowNavBarPadding)
      }
      navBarContent()
        .frame(height: config.defaultNavBarHeight)
    }.font(.system(size: 20, weight: .semibold, design: .rounded))
      .foregroundColor(theme.foreground.primary.color)
      .padding(.horizontal, config.horizontalPagePadding)
//      .padding(.top, config.belowNavBarPadding)
      .frame(height: title == nil
             ? max(config.defaultNavBarHeight, config.belowNavBarPadding)
             : titleHeight + config.belowNavBarPadding,
             alignment: .top)
  }
}
#endif
