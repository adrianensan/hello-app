import SwiftUI

import HelloCore

public struct ShareHelloButtonAction: HelloButtonAction {
  
  private var shareContent: @MainActor () async throws -> Any
  
  fileprivate init(content: @MainActor @escaping () async throws -> some Sendable) {
    self.shareContent = content
  }
  
  public func action(context: HelloButtonActionContext) async throws {
    guard let windowModel = context.environment[HelloWindowModel.self] else { return }
    let shareContent = try await shareContent()
#if os(iOS)
    (windowModel.window ?? (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow)?
      .rootViewController?
      .present(UIActivityViewController(activityItems: (shareContent as? [Any]) ?? [shareContent], applicationActivities: nil), animated: true, completion: nil)
#endif
  }
}

public extension HelloButtonAction where Self == ShareHelloButtonAction {
  static func share(content: @MainActor @escaping () async throws -> some Sendable) -> ShareHelloButtonAction {
    ShareHelloButtonAction(content: content)
  }
  
//  static func pushPage<Content: View>(id: String = String(describing: Content.self),
//                                      title: String,
//                                      content: @MainActor @escaping @autoclosure () -> Content) -> PushPageHelloButtonAction {
//    PushPageHelloButtonAction { PagerPage(id: id, name: title, view: content) }
//  }
}
