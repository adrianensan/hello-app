#if os(iOS)
import SwiftUI

@MainActor
public struct NavigationPage<Content: View, NavBarContent: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.helloPagerConfig) private var config
  
  @State private var scrollModel: HelloScrollModel
  @State private var isSmallSize: Bool = false
  
  private var title: String?
  private var allowScroll: Bool
  private var content: () -> Content
  private var navBarContent: () -> NavBarContent
  
  public init(title: String? = nil,
              allowScroll: Bool = true,
              model: HelloScrollModel? = nil,
              @ViewBuilder navBarContent: @escaping () -> NavBarContent,
              @ViewBuilder content: @escaping () -> Content) {
    self.title = title
    self.allowScroll = allowScroll
    self.content = content
    self.navBarContent = navBarContent
    _scrollModel = State(initialValue: model ?? HelloScrollModel())
  }
  
  private var navBarContentScrolls: Bool {
    config.overrideNavBarContentScrolls ?? isSmallSize
  }
  
  private var navBarHeight: CGFloat {
    if config.belowNavBarPadding > 0 {
      config.belowNavBarPadding + (title == nil ? 0 : 44)
    } else {
      config.defaultNavBarHeight
    }
  }
  
  public var body: some View {
    ZStack(alignment: .top) {
      HelloScrollView(
        allowScroll: allowScroll,
        model: scrollModel,
        content: {
          if navBarContentScrolls {
            NavigationPageBarScrolling(title: title, navBarContent: navBarContent)
          }
          content()
            .padding(.top, max(-scrollModel.effectiveScrollThreshold - 2, 0))
            .padding(.horizontal, config.horizontalPagePadding)
            .frame(maxWidth: .infinity)
            .background(ClearClickableView().onTapGesture {
              globalDismissKeyboard()
            })
//            .background(ClearClickableView())
        }).safeAreaInset(edge: .top, spacing: 0) {
          Color.clear.frame(height: !navBarContentScrolls ? navBarHeight : 0)
        }
      
      NavigationPageBarFixed(title: title, navBarContentScrolls: navBarContentScrolls, navBarContent: navBarContent)
    }.onChange(of: isSmallSize || title == nil, initial: true) {
      scrollModel.defaultScrollThreshold = config.overrideNavBarTitleScrollsDown == false || isSmallSize || title == nil ? 2 : -82
    }.environment(scrollModel)
      .observeSmallWindowSize(isSmallWindow: $isSmallSize)
  }
}

public extension NavigationPage where NavBarContent == EmptyView {
  public init(title: String? = nil,
              allowScroll: Bool = true,
              model: HelloScrollModel? = nil,
              @ViewBuilder content: @escaping () -> Content) {
    self.init(title: title,
              allowScroll: allowScroll,
              model: model,
              navBarContent: { EmptyView() },
              content: content)
  }
}
#endif
