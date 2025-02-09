import SwiftUI

import HelloCore

public struct HelloPageBarFixed<TitleContent: View, NavBarContent: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeAreaInsets
  @Environment(\.helloPagerConfig) private var config
  @Environment(HelloScrollModel.self) private var scrollModel
  #if os(iOS)
  @OptionalEnvironment(HelloSheetModel.self) private var sheetModel
  #endif
  
  @GestureState private var drag: CGSize?
  
  @ViewBuilder let titleContent: @MainActor () -> TitleContent
  @ViewBuilder let navBarContent: @MainActor () -> NavBarContent
  
  public var body: some View {
    HelloPageBar(titleContent: titleContent, navBarContent: navBarContent)
      .frame(maxWidth: .infinity)
      .padding(.top, safeAreaInsets.top)
      .padding(.bottom, config.navBarFadeTransitionMultiplier * (1 - scrollModel.scrollThresholdProgress) * -scrollModel.effectiveScrollThreshold)
      .padding(.top, 16)
      .padding(.horizontal, 2)
      .background(
        theme.header.backgroundView(isBaseLayer: false)
          .compositingGroup()
          .shadow(color: .black.opacity(0.12), radius: 24)
          .compositingGroup()
          .blur(radius: interpolate(.linear, from: 8, to: 0, progress: scrollModel.scrollThresholdProgress))
          .opacity(scrollModel.hasScrolled ? 1 : scrollModel.scrollThresholdProgress)
          .simultaneousGesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .updating($drag) { value, state, _ in
              state = value.translation
            })
          .allowsHitTesting(scrollModel.hasScrolled)
//          .animation(nil)
      ).padding(.top, -16)
      .padding(.horizontal, -2)
    //.padding(.bottom, -0.64 * (1 - scrollModel.scrollThresholdProgress) * -scrollModel.effectiveScrollThreshold)
      .opacity(config.navBarStyle == .scrollsWithContent && scrollModel.hasScrolled ? 0 : 1)
      .onChange(of: drag == nil) {
        #if os(iOS)
        sheetModel?.isDraggingNavBar = drag != nil
        #endif
      }
  }
}
