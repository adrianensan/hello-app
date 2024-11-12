import SwiftUI

import HelloCore

public struct PagerPage: Sendable, Identifiable {
  public var id: String
  public var name: String?
  public var view: @MainActor () -> AnyView
  public var options: PagerPageOptions
  var instanceID: String = .uuid
  
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
  public var navBarFadeTransitionMultiplier: CGFloat
  public var overrideNavBarTitleScrollsDown: Bool?
  public var allowsBack: Bool
  public var backGestureType: GestureType
  
  public init(navBarHeight: CGFloat = Self.defaultNavBarHeight,
              horizontalPagePadding: CGFloat = 20,
              belowNavBarPadding: CGFloat = 0,
              navBarStyle: NavigationPageNavigationBarStyle = .fixed,
              navBarFadeTransitionMultiplier: CGFloat = 1,
              overrideNavBarTitleScrollsDown: Bool? = nil,
              allowsBack: Bool = true,
              backGestureType: GestureType = .highPriority) {
    self.navBarHeight = navBarHeight
    self.horizontalPagePadding = horizontalPagePadding
    self.belowNavBarPadding = belowNavBarPadding
    self.navBarStyle = navBarStyle
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
  @ObservationIgnored var dismissed: [String] = []
  
  private var pageScrollModels: [String: HelloScrollModel] = [:]
  private var timePagePushed: TimeInterval = epochTime
  
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
  
  public var activePage: PagerPage? { viewStack.element(at: viewDepth - 1) }
  
  public var activePageID: String? { activePage?.id }
  
  public var currentPageType: String? { activePage?.options.type }
  
  public var activeScrollModel: HelloScrollModel? { activePageID.flatMap { pageScrollModels[$0] } }
  
  public var activePageIsReadyForDismiss: Bool { activeScrollModel?.readyForDismiss ?? true }
  
  func pageIndex(for pageID: String) -> Int? {
    viewStack.firstIndex { $0.id == pageID }
  }
  
  func backText(for pageID: String) -> String {
    viewStack.element(at: (pageIndex(for: pageID) ?? 0) - 1)?.name ?? "Back"
  }
  
  func canGoBack(from pageID: String) -> Bool {
    (activePage?.options.allowBackOverride ?? config.allowsBack) && pageIndex(for: pageID) ?? 0 > 0
  }
  
  func isDismissed(instanceID: String) -> Bool {
    dismissed.contains(instanceID)
  }
  
  public func push<Page: View>(id: String = String(describing: Page.self),
                               name: String? = nil,
                               animated: Bool = true,
                               withOptions options: PagerPageOptions = PagerPageOptions(),
                               view: @escaping @MainActor () -> Page) {
    Log.verbose(context: "Pager", "Attempting to push page \(id)")
    guard allowInteraction else { return }
//    dismissKeyboard()
    let pagesToRemove = viewStack.count - viewDepth
    if pagesToRemove > 0 {
      for _ in 0..<pagesToRemove {
        let removedPage = viewStack.popLast()
        dismissed.removeAll { $0 == removedPage?.instanceID }
      }
    }
    guard !viewStack.contains(where: { $0.id == id }) else { return }
    allowInteraction = false
    let newPage = PagerPage(id: id, name: name, view: view, options: options)
    viewStack.append(newPage)
    if !animated {
      self.viewDepth = self.viewStack.count
      self.allowInteraction = true
    } else {
      timePagePushed = epochTime
    }
  }
  
  public func pageReady(_ pageID: String) {
    let time = epochTime - timePagePushed
    Log.verbose(context: "Pager", "Page \(pageID) took \(time.string)s to prepare")
    guard viewDepth != viewStack.count else { return }
    Task {
      try? await Task.sleepForOneFrame()
      withAnimation(.pageAnimation) {
        viewDepth = viewStack.count
        allowInteraction = true
      }
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
    Log.verbose(context: "Pager", "Attempting to pop page")
    guard let activePage else {
      Log.error(context: "Pager", "Trying to pop view with no active page")
      return
    }
    let pageIDToRemove = activePage.instanceID
    dismissed.append(pageIDToRemove)
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
        backProgressModel.reset()
      }
    } else {
      viewDepth = viewStack.count - backPageCount
      backProgressModel.reset()
    }
    Task {
      try await Task.sleep(seconds: 0.32)
      guard dismissed.contains(pageIDToRemove) else { return }
      viewStack.removeAll { $0.instanceID == pageIDToRemove }
      dismissed.removeAll { $0 == pageIDToRemove }
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
