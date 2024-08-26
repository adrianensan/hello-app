import SwiftUI

import HelloCore

public struct PagerPage: Sendable, Identifiable {
  public var id: String
  public var name: String?
  public var view: @MainActor () -> AnyView
  public var options: PagerPageOptions
  var viewID: String = .uuid
  
  @MainActor
  public init(id: String = .uuid,
              name: String? = nil,
              view: @escaping @MainActor () -> some View,
              options: PagerPageOptions = PagerPageOptions()) {
    self.id = id
    self.name = name
    self.view = { AnyView(view()) }
    self.options = options
  }
  
  @MainActor
  public init(id: String = .uuid,
              name: String? = nil,
              view: @escaping @MainActor () -> AnyView,
              options: PagerPageOptions = PagerPageOptions()) {
    self.id = id
    self.name = name
    self.view = view
    self.options = options
  }
}

public enum NavigationPageNavigationBarStyle: Sendable {
  case fixed
  case scrollsWithContent
  case none
}

public struct HelloPagerConfig: Sendable {
  
  #if os(iOS)
  public static let defaultNavBarHeight: CGFloat = 60
  #else
  public static let defaultNavBarHeight: CGFloat = 56
  #endif
  
  public var navBarHeight: CGFloat
  public var horizontalPagePadding: CGFloat
  public var belowNavBarPadding: CGFloat
  public var navBarStyle: NavigationPageNavigationBarStyle
  public var navBarTrailingPadding: CGFloat
  public var navBarFadeTransitionMultiplier: CGFloat
  public var overrideNavBarTitleScrollsDown: Bool?
  public var allowsBack: Bool
  public var backGestureType: GestureType
  
  public init(navBarHeight: CGFloat = Self.defaultNavBarHeight,
              horizontalPagePadding: CGFloat = 16,
              belowNavBarPadding: CGFloat = 0,
              navBarStyle: NavigationPageNavigationBarStyle = .fixed,
              navBarTrailingPadding: CGFloat = 0,
              navBarFadeTransitionMultiplier: CGFloat = 1,
              overrideNavBarTitleScrollsDown: Bool? = nil,
              allowsBack: Bool = true,
              backGestureType: GestureType = .highPriority) {
    self.navBarHeight = navBarHeight
    self.horizontalPagePadding = horizontalPagePadding
    self.belowNavBarPadding = belowNavBarPadding
    self.navBarStyle = navBarStyle
    self.navBarTrailingPadding = navBarTrailingPadding
    self.navBarFadeTransitionMultiplier = navBarFadeTransitionMultiplier
    self.overrideNavBarTitleScrollsDown = overrideNavBarTitleScrollsDown
    self.allowsBack = allowsBack
    self.backGestureType = backGestureType
  }
}

public struct PagerPageOptions: Sendable {
  public var type: String?
  public var headerContentColorOverride: HelloColor?
  public var allowBackOverride: Bool?
  public var skipsWhenBack: Bool = false
  public var backAction: (@Sendable () -> Void)?
  
  public init(type: String? = nil,
                headerContentColorOverride: HelloColor? = nil, 
                allowBackOverride: Bool? = nil, 
                skipsWhenBack: Bool = false, 
                backAction: (@Sendable () -> Void)? = nil) {
    self.type = type
    self.headerContentColorOverride = headerContentColorOverride
    self.allowBackOverride = allowBackOverride
    self.skipsWhenBack = skipsWhenBack
    self.backAction = backAction
  }
}

public struct HelloPageConfig<Content: View>: Sendable {
  var id: String
  var view: @MainActor () -> Content
}

@MainActor
@Observable
public class PagerModel {
  public let id: String
  public private(set) var backProgressModel = BackProgressModel()
  public private(set) var viewStack: [PagerPage] = []
  public private(set) var viewDepth: Int = 0
  public var allowInteraction: Bool = true
  var config: HelloPagerConfig
  private var lastPage: String?
  
  private var pageScrollModels: [String: HelloScrollModel] = [:]
  
  public init(id: String = .uuid, config: HelloPagerConfig = HelloPagerConfig(), initialViewStack: [PagerPage]) {
    self.id = id
    self.config = config
    viewStack = initialViewStack
    viewDepth = initialViewStack.count
  }
  
  public init(id: String = .uuid, config: HelloPagerConfig = HelloPagerConfig(), rootView: @escaping @MainActor () -> some View) {
    self.id = id
    self.config = config
    viewStack = [PagerPage(view: rootView)]
    viewDepth = 1
  }
  
  public init(id: String = .uuid, config: HelloPagerConfig = HelloPagerConfig(), rootPage: PagerPage) {
    self.id = id
    self.config = config
    viewStack = [rootPage]
    viewDepth = 1
  }
  
  public var activePage: PagerPage? {
    if viewDepth > 0 && viewDepth <= viewStack.count {
      return viewStack[viewDepth - 1]
    } else {
      return nil
    }
  }
  
  public var activePageID: String? {
    activePage?.id
  }
  
  public var currentPageType: String? {
    activePage?.options.type
  }
  
  public var activeScrollModel: HelloScrollModel? {
    activePageID.flatMap { pageScrollModels[$0] }
  }
  
  public var activePageScrollOffset: CGFloat {
    activeScrollModel?.scrollOffset ?? 0
  }
  
  public func push<Page: View>(id: String = String(describing: Page.self),
                               name: String? = nil,
                               animated: Bool = true,
                               withOptions options: PagerPageOptions = PagerPageOptions(),
                               view: @escaping @MainActor () -> Page) {
    guard allowInteraction, !viewStack.contains(where: { $0.id == id }) else { return }
//    dismissKeyboard()
    let pagesToRemove = viewStack.count - viewDepth
    if pagesToRemove > 0 {
      for _ in 0..<pagesToRemove {
        if lastPage == id {
          viewDepth = viewStack.count
          return
        }
        _ = viewStack.popLast()
      }
    }
    allowInteraction = false
    lastPage = id
    let newPage = PagerPage(id: id, name: name, view: view, options: options)
    viewStack.append(newPage)
    if animated {
      Task {
        try await Task.sleepForOneFrame()
        withAnimation(.pageAnimation) {
          self.viewDepth = self.viewStack.count
        }
        Task {
          try await Task.sleep(seconds: 0.24)
          self.allowInteraction = true
        }
      }
    } else {
      self.viewDepth = self.viewStack.count
      self.allowInteraction = true
    }
  }
  
  public func replaceStack(with newViewStack: [PagerPage]) {
    viewStack = newViewStack
    viewDepth = newViewStack.count
  }
  
  public func replaceView(with newView: @escaping @MainActor () -> some View, options: PagerPageOptions = PagerPageOptions()) {
    _ = viewStack.popLast()
    let newPage = PagerPage(view: newView, options: options)
    viewStack.append(newPage)
  }
  
  public func popView(animated: Bool = true) {
    globalDismissKeyboard()
    let pagesToRemove = viewStack.count - viewDepth
    if pagesToRemove > 0 {
      for _ in 0..<pagesToRemove {
        if let removedPage = viewStack.popLast() {
          pageScrollModels[removedPage.id] = nil
        }
      }
    }
    guard viewStack.count > 1 else { return }
    Haptics.buttonFeedback()
    var backPageCount = 1
    if viewStack.count > 2 {
      if viewStack[viewStack.count - 2].options.skipsWhenBack {
        viewStack[viewStack.count - 2].options.backAction?()
        backPageCount += 1
      }
    }
    viewStack[viewStack.count - 1].options.backAction?()
    if animated {
      withAnimation(.pageAnimation) {
        viewDepth = viewStack.count - backPageCount
      }
    } else {
      viewDepth = viewStack.count - backPageCount
    }
    Task {
      try await Task.sleepForOneFrame()
      _ = viewStack.popLast()
    }
  }
  
  public func popPrevious() {
    guard viewStack.count > 1 else { return }
    viewStack.remove(at: viewStack.count - 2)
    viewDepth = viewStack.count - 1
  }
  
  public func set(allowBack: Bool) {
    guard var activePage = viewStack.last else { return }
    activePage.options.allowBackOverride = allowBack
    viewStack[viewStack.count - 1] = activePage
  }
  
  public func set(scrollModel: HelloScrollModel, for pageID: String) {
    pageScrollModels[pageID] = scrollModel
  }
}
