import SwiftUI

public struct HelloPage<Content: View, TitleContent: View, NavBarContent: View>: View {
  
  @OptionalEnvironment(PagerModel.self) private var pagerModel
  @Environment(\.theme) private var theme
  @Environment(\.helloPagerConfig) private var config
  @Environment(\.safeArea) private var safeAreaInsets
  #if os(iOS)
  @Environment(\.keyboardFrame) private var keyboardFrame
  #endif
  
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
  
  private var navBarStyle: HelloPageNavigationBarStyle {
    config.navBarStyle
  }
  
  private var navBarHeight: CGFloat {
    //    if config.belowNavBarPadding > 0 {
    //      config.belowNavBarPadding + (title == nil ? 0 : 44)
    //    } else {
    config.navBarHeight
    //    }
  }
  
  private var bottomSafeAreaInset: CGFloat {
    #if os(iOS)
    max(safeAreaInsets.bottom, keyboardFrame.height)
    #else
    safeAreaInsets.bottom
    #endif
  }
  
  public var body: some View {
    ZStack(alignment: .top) {
      if allowScroll {
        HelloScrollView(
          model: scrollModel,
          content: {
            VStack(spacing: 0) {
              #if os(iOS)
              if navBarStyle == .scrollsWithContent {
                HelloPageBarScrolling(titleContent: titleContent, navBarContent: {
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
          }).transformEnvironment(\.safeArea) {
            $0.top += navBarHeight
            $0.bottom = bottomSafeAreaInset
          }.scrollDismissesKeyboard(.interactively)
      } else {
        content()
          .padding(.top, navBarHeight + safeAreaInsets.top)
          .padding(.horizontal, config.horizontalPagePadding)
          .padding(.bottom, bottomSafeAreaInset + 16)
          .frame(maxWidth: .infinity)
          .background(ClearClickableView().onTapGesture {
            globalDismissKeyboard()
          })
      }
      
      HelloPageBarFixed(titleContent: titleContent, navBarContent: {
        HelloPageNavBarContent(navBarContent: navBarContent)
      })
    }.onChange(of: config.overrideNavBarTitleScrollsDown == false || isSmallSize || !(TitleContent.self == HelloPageTitle.self), initial: true) {
#if os(iOS)
      scrollModel.defaultScrollThreshold = config.overrideNavBarTitleScrollsDown == false || isSmallSize || !(TitleContent.self == HelloPageTitle.self) ? 0 : -82
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

public extension HelloPage where TitleContent == HelloPageTitle {
  init(title: String,
       allowScroll: Bool = true,
       model: HelloScrollModel,
       @ViewBuilder navBarContent: @escaping @MainActor () -> NavBarContent,
       @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.init(allowScroll: allowScroll,
              model: model,
              titleContent: { HelloPageTitle(title: title) },
              navBarContent: navBarContent,
              content: content)
  }
  
  init(title: String,
       allowScroll: Bool = true,
       showScrollIndicators: Bool = false,
       @ViewBuilder navBarContent: @escaping @MainActor () -> NavBarContent,
       @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.init(allowScroll: allowScroll,
              showScrollIndicators: showScrollIndicators,
              titleContent: { HelloPageTitle(title: title) },
              navBarContent: navBarContent,
              content: content)
  }
}

public extension HelloPage where TitleContent == EmptyView {
  init(allowScroll: Bool = true,
       model: HelloScrollModel,
       @ViewBuilder navBarContent: @escaping @MainActor () -> NavBarContent,
       @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.init(allowScroll: allowScroll,
              model: model,
              titleContent: { EmptyView() },
              navBarContent: navBarContent,
              content: content)
  }
  
  init(allowScroll: Bool = true,
       showScrollIndicators: Bool = false,
       @ViewBuilder navBarContent: @escaping @MainActor () -> NavBarContent,
       @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.init(allowScroll: allowScroll,
              showScrollIndicators: showScrollIndicators,
              titleContent: { EmptyView() },
              navBarContent: navBarContent,
              content: content)
  }
}

public extension HelloPage where TitleContent == HelloPageTitle, NavBarContent == EmptyView {
  init(title: String,
       allowScroll: Bool = true,
       model: HelloScrollModel,
       @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.init(title: title,
              allowScroll: allowScroll,
              model: model,
              navBarContent: { EmptyView() },
              content: content)
  }
  
  init(title: String,
       allowScroll: Bool = true,
       showScrollIndicators: Bool = false,
       @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.init(title: title,
              allowScroll: allowScroll,
              model: HelloScrollModel(showScrollIndicator: showScrollIndicators),
              navBarContent: { EmptyView() },
              content: content)
  }
}

public extension HelloPage where TitleContent == EmptyView, NavBarContent == EmptyView {
  init(allowScroll: Bool = true,
       model: HelloScrollModel,
       @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.init(allowScroll: allowScroll,
              model: model,
              titleContent: { EmptyView() },
              navBarContent: { EmptyView() },
              content: content)
  }
  
  init(allowScroll: Bool = true,
       showScrollIndicators: Bool = false,
       @ViewBuilder content: @escaping @MainActor () -> Content) {
    self.init(allowScroll: allowScroll,
              model: HelloScrollModel(showScrollIndicator: showScrollIndicators),
              titleContent: { EmptyView() },
              navBarContent: { EmptyView() },
              content: content)
  }
}
