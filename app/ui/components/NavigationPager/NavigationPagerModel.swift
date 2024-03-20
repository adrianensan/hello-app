import SwiftUI

import HelloCore

public struct PagerPage: Sendable, Identifiable {
  public var id: String
  public var view: AnyView
  public var options: PagerPageOptions
  
  @MainActor
  public init(id: String = UUID().uuidString,
              view: some View,
              options: PagerPageOptions = PagerPageOptions()) {
    self.id = id
    self.view = AnyView(view.id(id))
    self.options = options
  }
  
  @MainActor
  public init(id: String = UUID().uuidString,
              view: AnyView,
              options: PagerPageOptions = PagerPageOptions()) {
    self.id = id
    self.view = view
    self.options = options
  }
}

public struct HelloPagerConfig: Sendable {
  public var defaultNavBarHeight: CGFloat
  public var horizontalPagePadding: CGFloat
  public var overrideNavBarContentScrolls: Bool?
  public var allowsBack: Bool
  
  public init(defaultNavBarHeight: CGFloat = 60,
              horizontalPagePadding: CGFloat = 16,
              overrideNavBarContentScrolls: Bool? = nil,
              allowsBack: Bool = true) {
    self.defaultNavBarHeight = defaultNavBarHeight
    self.horizontalPagePadding = horizontalPagePadding
    self.overrideNavBarContentScrolls = overrideNavBarContentScrolls
    self.allowsBack = allowsBack
  }
}

public struct PagerPageOptions: Sendable {
  public var id: String = UUID().uuidString
  public var type: String?
  public var headerContentColorOverride: HelloColor?
  public var allowBackOverride: Bool?
  public var skipsWhenBack: Bool = false
  public var backAction: (@Sendable () -> Void)?
  
  public init(id: String = UUID().uuidString, 
                type: String? = nil, 
                headerContentColorOverride: HelloColor? = nil, 
                allowBackOverride: Bool? = nil, 
                skipsWhenBack: Bool = false, 
                backAction: (@Sendable () -> Void)? = nil) {
    self.id = id
    self.type = type
    self.headerContentColorOverride = headerContentColorOverride
    self.allowBackOverride = allowBackOverride
    self.skipsWhenBack = skipsWhenBack
    self.backAction = backAction
  }
}

@MainActor
@Observable
public class PagerModel {
  public private(set) var backProgressModel = BackProgressModel()
  public private(set) var viewStack: [PagerPage] = []
  public private(set) var viewDepth: Int = 0
  public var allowInteraction: Bool = true
  var config: HelloPagerConfig
  private var lastPage: String?
  
  public init(config: HelloPagerConfig = HelloPagerConfig(), initialViewStack: [PagerPage]) {
    self.config = config
    viewStack = initialViewStack
    viewDepth = initialViewStack.count
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
  
  public func push<Page: View>(view: Page, animated: Bool = true, withOptions options: PagerPageOptions = PagerPageOptions()) {
    guard allowInteraction else { return }
//    dismissKeyboard()
    let pagesToRemove = viewStack.count - viewDepth
    if pagesToRemove > 0 {
      for _ in 0..<pagesToRemove {
        if lastPage == String(describing: view) {
          viewDepth = viewStack.count
          return
        }
        _ = viewStack.popLast()
      }
    }
    allowInteraction = false
    lastPage = String(describing: view)
    let newPage = PagerPage(id: options.id, view: view, options: options)
    viewStack.append(newPage)
    if animated {
      Task {
        try await Task.sleep(nanoseconds: 25_000_000)
        self.viewDepth = self.viewStack.count
        Task {
          try await Task.sleep(nanoseconds: 240_000_000)
          self.allowInteraction = true
        }
      }
    } else {
      self.viewDepth = self.viewStack.count
      self.allowInteraction = true
    }
  }
  
  public func replaceView(with newView: some View, options: PagerPageOptions = PagerPageOptions()) {
    _ = viewStack.popLast()
    let newPage = PagerPage(id: options.id, view: newView, options: options)
    viewStack.append(newPage)
  }
  
  public func popView(animated: Bool = true) {
//    dismissKeyboard()
    let pagesToRemove = viewStack.count - viewDepth
    if pagesToRemove > 0 {
      for _ in 0..<pagesToRemove {
        _ = viewStack.popLast()
      }
    }
    guard viewStack.count > 1 else { return }
    var backPageCount = 1
    if viewStack.count > 2 {
      if viewStack[viewStack.count - 2].options.skipsWhenBack {
        viewStack[viewStack.count - 2].options.backAction?()
        backPageCount += 1
      }
    }
    viewStack[viewStack.count - 1].options.backAction?()
    viewDepth = viewStack.count - backPageCount
    Task {
      try await Task.sleep(seconds: 0.02)
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
}
