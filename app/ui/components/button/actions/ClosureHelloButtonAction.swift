import SwiftUI

public struct ClosureHelloButtonAction: HelloButtonAction {
  
  public var closure: @MainActor () async throws -> Void
  
  fileprivate init(closure: @MainActor @escaping () async throws -> Void) {
    self.closure = closure
  }
  
  public func action(context: HelloButtonActionContext) async throws {
    try await closure()
  }
}

public extension HelloButtonAction where Self == ClosureHelloButtonAction {
  static func closure(_ closure: @MainActor @escaping () async throws -> Void) -> ClosureHelloButtonAction {
    ClosureHelloButtonAction(closure: closure)
  }
}
