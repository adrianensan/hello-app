#if os(iOS)
import SwiftUI

@MainActor
public struct NavigationPage<Content: View, NavBarContent: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.helloPagerConfig) private var config
  @Environment(\.safeArea) private var safeAreaInsets
  
  @State private var scrollModel: HelloScrollModel
  
  private var allowScroll: Bool
  private var navBarContentScrolls: Bool
  private var content: Content
  private var navBarContent: NavBarContent
  
  public init(allowScroll: Bool = true,
              navBarContentScrolls: Bool = false,
              model: HelloScrollModel? = nil,
              @ViewBuilder navBarContent: () -> NavBarContent,
              @ViewBuilder content: @escaping () -> Content) {
    self.allowScroll = allowScroll
    self.navBarContentScrolls = navBarContentScrolls
    self.content = content()
    self.navBarContent = navBarContent()
    _scrollModel = State(initialValue: model ?? HelloScrollModel())
  }
  
  public var body: some View {
//    let _ = print(Self._printChanges())
    ZStack(alignment: .top) {
      HelloScrollView(
        allowScroll: allowScroll,
        showsIndicators: false,
        model: scrollModel,
        content: {
          if navBarContentScrolls {
            navBarContent
              .font(.system(size: 20, weight: .semibold, design: .rounded))
              .foregroundColor(theme.text.primary.color)
              .padding(.horizontal, config.horizontalPagePadding)
              .frame(height: config.defaultNavBarHeight)
              .opacity(scrollModel.hasScrolled ? 1 : 0)
          }
          content
            .padding(.top, (navBarContentScrolls ? 0 : config.defaultNavBarHeight) + 8)
            .padding(.horizontal, config.horizontalPagePadding)
            .frame(maxWidth: .infinity)
//            .background(ClearClickableView())
      })
      
      navBarContent
        .font(.system(size: 20, weight: .semibold, design: .rounded))
        .foregroundColor(theme.text.primary.color)
        .padding(.horizontal, config.horizontalPagePadding)
        .offset(y: 0.5 * scrollModel.overscroll)
        .frame(height: config.defaultNavBarHeight)
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
        .opacity(navBarContentScrolls && scrollModel.hasScrolled ? 0 : 1)
    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}
#endif
