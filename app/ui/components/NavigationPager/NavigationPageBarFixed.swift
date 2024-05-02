#if os(iOS)
import SwiftUI

@MainActor
public struct NavigationPageBarFixed<NavBarContent: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeAreaInsets
  @Environment(\.helloPagerConfig) private var config
  @Environment(HelloScrollModel.self) private var scrollModel
  
  let title: String?
  let navBarContent: () -> NavBarContent
  
  public var body: some View {
    NavigationPageBar(title: title, navBarContent: navBarContent)
      .frame(maxWidth: .infinity)
      .padding(.top, safeAreaInsets.top)
      .background(
        ZStack {
          Rectangle().fill(.ultraThinMaterial)
          theme.backgroundColor.opacity(0.8)
        }.compositingGroup()
          .shadow(color: .black.opacity(0.12), radius: 24)
          .opacity(scrollModel.hasScrolled ? 1 : 0)
      ).frame(maxHeight: .infinity, alignment: .top)
      .opacity(config.navBarStyle == .scrollsWithContent && scrollModel.hasScrolled ? 0 : 1)
  }
}
#endif
