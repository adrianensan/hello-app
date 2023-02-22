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
  
  public func push<Page: View>(view: Page, animated: Bool = true) {
    if let view = view as? AnyView {
      realViewStack.append(view)
    } else {
      realViewStack.append(AnyView(view.id(UUID().uuidString)))
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
  
  public func popView(animated: Bool = true) {
    guard realViewStack.count > 1 else { return }
    viewDepth = realViewStack.count - 1
    _ = realViewStack.popLast()
  }
  
  private func commitViewStackUpdate() {
    viewStack = realViewStack
  }
}
