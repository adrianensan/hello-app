import SwiftUI

public struct NoHelloButtonAction: HelloButtonAction {
  
  fileprivate init() {}
  
  public func action(context: HelloButtonActionContext) async throws {}
}

public extension HelloButtonAction where Self == NoHelloButtonAction {
  static var noop: NoHelloButtonAction {
    NoHelloButtonAction()
  }
}
