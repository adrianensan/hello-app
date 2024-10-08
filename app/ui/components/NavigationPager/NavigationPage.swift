import SwiftUI

public struct NavigationPage<Content: View, TitleContent: View, NavBarContent: View>: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.helloPagerConfig) private var config
  @OptionalEnvironment(PagerModel.self) private var pagerModel
  
  @State private var scrollModel: HelloScrollModel
  @State private var isSmallSize: Bool = false
  
  private var allowScroll: Bool
  @ViewBuilder private var content: @MainActor () -> Content
  @ViewBuilder private var titleContent: @MainActor () -> TitleContent
  @ViewBuilder private var navBarContent: @MainActor () -> NavBarContent
  
  public init(allowScroll: Bool = true,
              model: HelloScrollModel? = nil,
              @ViewBuilder titleContent: @escaping @MainActor () -> TitleContent,
              @ViewBuilder navBarContent: @escaping @MainActor () -> NavBarContent,
              @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.allowScroll = allowScroll
    self.content = content
    self.titleContent = titleContent
    self.navBarContent = navBarContent
    _scrollModel = State(initialValue: model ?? HelloScrollModel())
  }
  
  public init(allowScroll: Bool = true,
              showScrollIndicators: Bool,
              @ViewBuilder titleContent: @escaping @MainActor () -> TitleContent,
              @ViewBuilder navBarContent: @escaping @MainActor () -> NavBarContent,
              @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.allowScroll = allowScroll
    self.content = content
    self.titleContent = titleContent
    self.navBarContent = navBarContent
    _scrollModel = State(initialValue: HelloScrollModel(showScrollIndicator: showScrollIndicators))
  }
  
  private var navBarStyle: NavigationPageNavigationBarStyle {
    config.navBarStyle ?? (isSmallSize ? .scrollsWithContent : .fixed)
  }
  
  private var navBarHeight: CGFloat {
//    if config.belowNavBarPadding > 0 {
//      config.belowNavBarPadding + (title == nil ? 0 : 44)
//    } else {
      config.navBarHeight
//    }
  }
  
  public var body: some View {
    ZStack(alignment: .top) {
      HelloScrollView(
        allowScroll: allowScroll,
        model: scrollModel,
        content: {
          VStack(spacing: 0) {
            #if os(iOS)
            if navBarStyle == .scrollsWithContent {
              NavigationPageBarScrolling(titleContent: titleContent, navBarContent: {
                HelloPageNavBarContent(navBarContent: navBarContent)
              })
            }
            #endif
            
            content()
              .padding(.top, max(-scrollModel.effectiveScrollThreshold, 0) + (scrollModel.scrollThreshold == nil && scrollModel.effectiveScrollThreshold < 0 ? 8 : 0))
              .padding(.horizontal, config.horizontalPagePadding)
              .padding(.bottom, 16)
              .frame(maxWidth: .infinity)  
          }.background(ClearClickableView().onTapGesture {
            globalDismissKeyboard()
          })
//            .background(ClearClickableView())
        }).safeAreaInset(edge: .top, spacing: 0) {
          Color.clear.frame(height: navBarStyle != .scrollsWithContent ? navBarHeight : 0)
        }
      
      #if os(iOS)
      NavigationPageBarFixed(titleContent: titleContent, navBarContent: {
        HelloPageNavBarContent(navBarContent: navBarContent)
      })
      #endif
    }.onChange(of: config.overrideNavBarTitleScrollsDown == false || isSmallSize || !(TitleContent.self == NavigationPageTitle.self), initial: true) {
      #if os(iOS)
      scrollModel.defaultScrollThreshold = config.overrideNavBarTitleScrollsDown == false || isSmallSize || !(TitleContent.self == NavigationPageTitle.self) ? 0 : -82
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

public extension NavigationPage where TitleContent == NavigationPageTitle {
  public init(title: String,
              allowScroll: Bool = true,
              model: HelloScrollModel? = nil,
              @ViewBuilder navBarContent: @escaping @MainActor () -> NavBarContent,
              @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.init(allowScroll: allowScroll,
              model: model,
              titleContent: { NavigationPageTitle(title: title) },
              navBarContent: navBarContent,
              content: content)
  }
  
  public init(title: String,
              allowScroll: Bool = true,
              showScrollIndicators: Bool,
              @ViewBuilder navBarContent: @escaping @MainActor () -> NavBarContent,
              @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.init(allowScroll: allowScroll,
              showScrollIndicators: showScrollIndicators,
              titleContent: { NavigationPageTitle(title: title) },
              navBarContent: navBarContent,
              content: content)
  }
}

public extension NavigationPage where TitleContent == EmptyView {
  public init(allowScroll: Bool = true,
              model: HelloScrollModel? = nil,
              @ViewBuilder navBarContent: @escaping @MainActor () -> NavBarContent,
              @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.init(allowScroll: allowScroll,
              model: model,
              titleContent: { EmptyView() },
              navBarContent: navBarContent,
              content: content)
  }
  
  public init(allowScroll: Bool = true,
              showScrollIndicators: Bool,
              @ViewBuilder navBarContent: @escaping @MainActor () -> NavBarContent,
              @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.init(allowScroll: allowScroll,
              showScrollIndicators: showScrollIndicators,
              titleContent: { EmptyView() },
              navBarContent: navBarContent,
              content: content)
  }
}

public extension NavigationPage where TitleContent == NavigationPageTitle, NavBarContent == EmptyView {
  init(title: String,
       allowScroll: Bool = true,
       model: HelloScrollModel? = nil,
       @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.init(title: title,
              allowScroll: allowScroll,
              model: model,
              navBarContent: { EmptyView() },
              content: content)
  }
  
  init(title: String,
       allowScroll: Bool = true,
       showScrollIndicators: Bool,
       @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.init(title: title,
              allowScroll: allowScroll,
              model: HelloScrollModel(showScrollIndicator: showScrollIndicators),
              navBarContent: { EmptyView() },
              content: content)
  }
}

public extension NavigationPage where TitleContent == EmptyView, NavBarContent == EmptyView {
  init(allowScroll: Bool = true,
       model: HelloScrollModel? = nil,
       @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.init(allowScroll: allowScroll,
              model: model,
              titleContent: { EmptyView() },
              navBarContent: { EmptyView() },
              content: content)
  }
  
  init(allowScroll: Bool = true,
       showScrollIndicators: Bool,
       @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.init(allowScroll: allowScroll,
              model: HelloScrollModel(showScrollIndicator: showScrollIndicators),
              titleContent: { EmptyView() },
              navBarContent: { EmptyView() },
              content: content)
  }
}
