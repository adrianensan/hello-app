import SwiftUI

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
  
  private var navBarStyle: NavigationPageNavigationBarStyle {
    config.navBarStyle ?? (isSmallSize ? .scrollsWithContent : .fixed)
  }
  
  private var navBarHeight: CGFloat {
    if config.belowNavBarPadding > 0 {
      config.belowNavBarPadding + (title == nil ? 0 : 44)
    } else {
      config.navBarHeight
    }
  }
  
  public var body: some View {
    ZStack(alignment: .top) {
      HelloScrollView(
        allowScroll: allowScroll,
        model: scrollModel,
        content: {
          #if os(iOS)
          if navBarStyle == .scrollsWithContent {
            NavigationPageBarScrolling(title: title, navBarContent: navBarContent)
          }
          #endif
          
          content()
            .padding(.top, max(-scrollModel.effectiveScrollThreshold - 2, 0))
            .padding(.horizontal, config.horizontalPagePadding)
            .frame(maxWidth: .infinity)
            .background(ClearClickableView().onTapGesture {
              globalDismissKeyboard()
            })
//            .background(ClearClickableView())
        }).safeAreaInset(edge: .top, spacing: 0) {
          Color.clear.frame(height: navBarStyle != .scrollsWithContent ? navBarHeight : 0)
        }
      
      NavigationPageBarFixed(title: title, navBarContent: navBarContent)
    }.onChange(of: isSmallSize || title == nil, initial: true) {
      #if os(iOS)
      scrollModel.defaultScrollThreshold = config.overrideNavBarTitleScrollsDown == false || isSmallSize || title == nil ? -2 : -82
      #else
      scrollModel.defaultScrollThreshold = 0
      #endif
    }.environment(scrollModel)
      .observeSmallWindowSize(isSmallWindow: $isSmallSize)
      .transformEnvironment(\.helloPagerConfig) {
        $0.navBarStyle = navBarStyle
      }
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
