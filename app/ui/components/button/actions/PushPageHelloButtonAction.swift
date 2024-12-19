import SwiftUI

import HelloCore

public struct PushPageHelloButtonAction: HelloButtonAction {
  
  private var page: @MainActor () -> PagerPage
  
  fileprivate init(page: @MainActor @escaping () -> PagerPage) {
    self.page = page
  }
  
  public func action(context: HelloButtonActionContext) async throws {
    guard let pagerModel = context.environment[HelloPagerModel.self] else { return }
    let page = try await page()
    pagerModel.push(page: page)
  }
}

public extension HelloButtonAction where Self == PushPageHelloButtonAction {
  static func pushPage<Content: View>(id: String = String(describing: Content.self),
                                      title: String,
                                      content: @MainActor @escaping () -> Content) -> PushPageHelloButtonAction {
    PushPageHelloButtonAction { PagerPage(id: id, name: title, view: content) }
  }
  
//  static func pushPage<Content: View>(id: String = String(describing: Content.self),
//                                      title: String,
//                                      content: @MainActor @escaping @autoclosure () -> Content) -> PushPageHelloButtonAction {
//    PushPageHelloButtonAction { PagerPage(id: id, name: title, view: content) }
//  }
}
