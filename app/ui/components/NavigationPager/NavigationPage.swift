#if os(iOS)
import SwiftUI

public struct NavigationPage<Content: View, NavBarContent: View>: View {
  
  @Environment(\.theme) var theme
  
  @EnvironmentObject var uiProperties: UIProperties
  
  @State private var overscroll: CGFloat = 0
  @State private var hasScrolled: Bool = false
  
  @Binding private var scrollToTop: Bool
  
  var allowScroll: Bool
  var content: Content
  var navBarContent: NavBarContent?
  
  public init(allowScroll: Bool = true,
              scrollToTopTrigger: Binding<Bool> = .constant(false),
              @ViewBuilder navBarContent: () -> NavBarContent,
              @ViewBuilder content: @escaping () -> Content) {
    self.allowScroll = allowScroll
    self._scrollToTop = scrollToTopTrigger
    self.content = content()
    self.navBarContent = navBarContent()
  }
  
  public var body: some View {
    ZStack {
      TopBlurScrollView(allowScroll: allowScroll,
                        showsIndicators: false,
                        scrollToTopTrigger: $scrollToTop,
                        onScrollUpdate: { scrollOffset in
        let overscrollTarget = max(0, scrollOffset)
        if overscroll != overscrollTarget {
          overscroll = overscrollTarget
        }
        
        let hasScrolledTarget = scrollOffset < -16
        if hasScrolled != hasScrolledTarget {
          hasScrolled = hasScrolledTarget
        }
        
      }) {
        content.padding(.top, 72)
          .padding(.horizontal, 16)
          .frame(maxWidth: .infinity)
          .background(ClearClickableView())
      }
      
      ZStack {
        navBarContent
          .font(.system(size: 20, weight: .semibold, design: .rounded))
          .foregroundColor(theme.text.primaryColor)
          .frame(height: 44)
          .padding(.horizontal, 16)
          .offset(y: 0.5 * overscroll)
      }.frame(height: 60)
        .frame(maxWidth: .infinity)
        .padding(.top, uiProperties.safeAreaInsets.top)
        .background(
          ZStack {
            Rectangle().fill(.ultraThinMaterial)
            theme.backgroundColor.opacity(0.8)
          }.compositingGroup()
            .shadow(color: .black.opacity(0.12), radius: 24)
            .opacity(hasScrolled ? 1 : 0)
        ).frame(maxHeight: .infinity, alignment: .top)
    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
  }
}
#endif
