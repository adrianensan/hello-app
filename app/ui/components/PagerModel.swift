import SwiftUI
import Combine

import HelloCore

@MainActor
public class PagerViewModel: ObservableObject {
  public var realViewStack: [AnyView] = []
  @Published public var viewStack: [AnyView] = []
  @Published public var viewDepth: Int = 0
  
  public init(initialViewStack: [AnyView]) {
    realViewStack = initialViewStack
    viewStack = initialViewStack
    viewDepth = initialViewStack.count
  }
  
  public func push(view: some View, animated: Bool = true) {
    if let view = view as? AnyView {
      realViewStack.append(view)
    } else {
      realViewStack.append(AnyView(view))
    }
    commitViewStackUpdate()
    if animated {
      Task {
        try await Task.sleep(nanoseconds: 25_000_000)
        self.viewDepth = self.realViewStack.count
      }
    } else {
      self.viewDepth = self.realViewStack.count
    }
  }
  
  public func replaceView(with newView: some View) {
    _ = realViewStack.popLast()
    if let view = newView as? AnyView {
      realViewStack.append(view)
    } else {
      realViewStack.append(AnyView(newView))
    }
    commitViewStackUpdate()
  }
  
  public func popView(animated: Bool = true) {
    guard realViewStack.count > 1 else { return }
    viewDepth = realViewStack.count - 1
    _ = realViewStack.popLast()
  }
  
  private func commitViewStackUpdate() {
    viewStack = realViewStack
  }
}
