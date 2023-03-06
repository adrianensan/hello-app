import SwiftUI

import HelloCore

public struct PagerPageOptions {
  public var id: String = UUID().uuidString
  public var type: String?
  public var headerContentColorOverride: HelloColor?
  public var allowBackOverride: Bool?
  public var skipsWhenBack: Bool = false
  public var backAction: (() -> Void)?
  
  public init(id: String = UUID().uuidString, 
                type: String? = nil, 
                headerContentColorOverride: HelloColor? = nil, 
                allowBackOverride: Bool? = nil, 
                skipsWhenBack: Bool = false, 
                backAction: (() -> Void)? = nil) {
    self.id = id
    self.type = type
    self.headerContentColorOverride = headerContentColorOverride
    self.allowBackOverride = allowBackOverride
    self.skipsWhenBack = skipsWhenBack
    self.backAction = backAction
  }
}

@MainActor
public class PagerModel: ObservableObject {
  public var backProgressModel = BackProgressModel()
  @Published public var viewStack: [AnyView] = []
  public var viewStackOptions: [PagerPageOptions] = []
  @Published public var viewDepth: Int = 0
  @Published public var allowInteraction: Bool = true
  private var lastPage: String?
  
  
  public init(initialViewStack: [AnyView], initialViewStackOptions: [Int: PagerPageOptions] = [:]) {
    viewStack = initialViewStack
    viewDepth = initialViewStack.count
    for i in 0..<viewDepth {
      viewStackOptions.append(initialViewStackOptions[i] ?? .init())
    }
  }
  
  public var currentPageType: String? {
    if viewDepth > 0 {
      return viewStackOptions[viewDepth - 1].type
    } else {
      return nil
    }
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
        _ = viewStackOptions.popLast()
      }
    }
    allowInteraction = false
    lastPage = String(describing: view)
    viewStackOptions.append(options)
    if let view = view as? AnyView {
      viewStack.append(view)
    } else {
      viewStack.append(AnyView(view.id(UUID().uuidString)))
    }
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
    viewStack.popLast()
    viewStackOptions.popLast()
    if let view = newView as? AnyView {
      viewStack.append(view)
    } else {
      viewStack.append(AnyView(newView.id(UUID().uuidString)))
    }
    viewStackOptions.append(options)
  }
  
  public func popView(animated: Bool = true) {
//    dismissKeyboard()
    let pagesToRemove = viewStack.count - viewDepth
    if pagesToRemove > 0 {
      for _ in 0..<pagesToRemove {
        _ = viewStack.popLast()
        _ = viewStackOptions.popLast()
      }
    }
    guard viewStack.count > 1 else { return }
    var backPageCount = 1
    if viewStackOptions.count > 2 {
      if viewStackOptions[viewStack.count - 2].skipsWhenBack {
        viewStackOptions[viewStack.count - 2].backAction?()
        backPageCount += 1
      }
    }
    viewStackOptions[viewStack.count - 1].backAction?()
    viewDepth = viewStack.count - backPageCount
    Task {
      try await Task.sleep(seconds: 0.02)
      _ = viewStack.popLast()
      _ = viewStackOptions.popLast()
    }
  }
  
  public func popPrevious() {
    guard viewStack.count > 1 else { return }
    viewStack.remove(at: viewStack.count - 2)
    viewStackOptions.remove(at: viewStackOptions.count - 2)
    viewDepth = viewStack.count - 1
  }
}
