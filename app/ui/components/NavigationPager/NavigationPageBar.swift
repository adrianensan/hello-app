#if os(iOS)
import SwiftUI

@MainActor
public struct NavigationPageBar<NavBarContent: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.helloPagerConfig) private var config
  @Environment(HelloScrollModel.self) private var scrollModel
  
  let title: String?
  let navBarContent: () -> NavBarContent
  
  public var body: some View {
    ZStack {
      if let title {
        NavigationPageTitle(title: title)
          .environment(scrollModel)
      }
      navBarContent()
    }.font(.system(size: 20, weight: .semibold, design: .rounded))
      .foregroundColor(theme.foreground.primary.color)
      .padding(.horizontal, config.horizontalPagePadding)
      .frame(height: config.defaultNavBarHeight)
  }
}
#endif
