#if os(iOS)
import SwiftUI

@MainActor
public struct NavigationPage<Content: View, NavBarContent: View>: View {
  
  @Environment(\.theme) var theme
  @Environment(\.helloPagerConfig) var config
  @Environment(\.safeArea) var safeAreaInsets
  
  @State private var overscroll: CGFloat = 0
  @State private var hasScrolled: Bool = false
  @State private var scrollOffset: CGFloat = 0
  @State private var dismissProgress: CGFloat = 0
  
  @Binding private var scrollToTop: Bool
  
  var allowScroll: Bool
  var navBarContentScrolls: Bool
  var content: Content
  var navBarContent: NavBarContent?
  var customNavBarContent: ((_ scrollOffset: CGFloat, _ dismissProgress: CGFloat) -> NavBarContent)?
  
  public init(allowScroll: Bool = true,
              navBarContentScrolls: Bool = false,
              scrollToTopTrigger: Binding<Bool> = .constant(false),
              @ViewBuilder navBarContent: () -> NavBarContent,
              @ViewBuilder content: @escaping () -> Content) {
    self.allowScroll = allowScroll
    self.navBarContentScrolls = navBarContentScrolls
    self._scrollToTop = scrollToTopTrigger
    self.content = content()
    self.navBarContent = navBarContent()
  }
  
  public init(allowScroll: Bool = true,
              navBarContentScrolls: Bool = false,
              scrollToTopTrigger: Binding<Bool> = .constant(false),
              @ViewBuilder navBarContent: @escaping (_ scrollOffset: CGFloat, _ dismissProgress: CGFloat) -> NavBarContent,
              @ViewBuilder content: @escaping () -> Content) {
    self.allowScroll = allowScroll
    self.navBarContentScrolls = navBarContentScrolls
    self._scrollToTop = scrollToTopTrigger
    self.content = content()
    self.customNavBarContent = navBarContent
  }
  
  public var body: some View {
    ZStack(alignment: .top) {
      HelloScrollView(
        allowScroll: allowScroll,
        showsIndicators: false,
        scrollToTopTrigger: $scrollToTop,
        onScrollUpdate: { scrollOffset in
          let overscrollTarget = max(0, scrollOffset)
          if overscroll != overscrollTarget {
            overscroll = overscrollTarget
          }
          
          let hasScrolledTarget = scrollOffset < 0
          if hasScrolled != hasScrolledTarget {
            hasScrolled = hasScrolledTarget
          }
          if customNavBarContent != nil && self.scrollOffset != scrollOffset {
            self.scrollOffset = scrollOffset
          }
        },
        onDismissUpdate: { dismissProgress in
          if customNavBarContent != nil && self.dismissProgress != dismissProgress {
            self.dismissProgress = dismissProgress
          }
        },
        content: {
          if navBarContentScrolls, let navBarContent {
            navBarContent
              .font(.system(size: 20, weight: .semibold, design: .rounded))
              .foregroundColor(theme.text.primary.color)
              .padding(.horizontal, config.horizontalPagePadding)
              .frame(height: config.defaultNavBarHeight)
              .opacity(hasScrolled ? 1 : 0)
          }
          content
            .padding(.top, (navBarContentScrolls ? 0 : config.defaultNavBarHeight) + 8)
            .padding(.horizontal, config.horizontalPagePadding)
            .frame(maxWidth: .infinity)
//            .background(ClearClickableView())
      })
      
      ZStack {
        if let customNavBarContent {
          customNavBarContent(scrollOffset, dismissProgress)
        } else if let navBarContent {
          navBarContent
        }
      }.font(.system(size: 20, weight: .semibold, design: .rounded))
        .foregroundColor(theme.text.primary.color)
        .padding(.horizontal, config.horizontalPagePadding)
        .offset(y: 0.5 * overscroll)
        .frame(height: config.defaultNavBarHeight)
        .frame(maxWidth: .infinity)
        .padding(.top, safeAreaInsets.top)
        .background(
          ZStack {
            Rectangle().fill(.ultraThinMaterial)
            theme.backgroundColor.opacity(0.8)
          }.compositingGroup()
            .shadow(color: .black.opacity(0.12), radius: 24)
            .opacity(hasScrolled ? 1 : 0)
        ).frame(maxHeight: .infinity, alignment: .top)
        .opacity(navBarContentScrolls && hasScrolled ? 0 : 1)
    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}
#endif
