import SwiftUI

import HelloCore

public struct NavigationPageBarFixed<NavBarContent: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeAreaInsets
  @Environment(\.helloPagerConfig) private var config
  @Environment(HelloScrollModel.self) private var scrollModel
  
  let title: String?
  let navBarContent: @MainActor () -> NavBarContent
  
  public var body: some View {
    NavigationPageBar(title: title, navBarContent: navBarContent)
      .frame(maxWidth: .infinity)
      .padding(.top, safeAreaInsets.top)
      .padding(.bottom, config.navBarFadeTransitionMultiplier * (1 - scrollModel.scrollThresholdProgress) * -scrollModel.effectiveScrollThreshold)
      .padding(.top, 16)
      .background(
        ZStack {
          Rectangle().fill(.ultraThinMaterial)
          theme.header.backgroundColor.opacity(0.8)
        }.compositingGroup()
          .shadow(color: .black.opacity(0.12), radius: 24)
          .compositingGroup()
          .blur(radius: interpolate(.linear, from: 8, to: 0, progress: scrollModel.scrollThresholdProgress))
          .opacity(scrollModel.hasScrolled ? 1 : scrollModel.scrollThresholdProgress)
          .allowsHitTesting(scrollModel.hasScrolled)
//          .animation(nil)
      ).padding(.top, -16)
    //.padding(.bottom, -0.64 * (1 - scrollModel.scrollThresholdProgress) * -scrollModel.effectiveScrollThreshold)
      .frame(maxHeight: .infinity, alignment: .top)
      .opacity(config.navBarStyle == .scrollsWithContent && scrollModel.hasScrolled ? 0 : 1)
  }
}
