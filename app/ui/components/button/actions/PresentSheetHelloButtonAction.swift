#if os(iOS)
import SwiftUI

import HelloCore

public struct PresentSheetHelloButtonAction: HelloButtonAction {
  
  private var sheet: @MainActor () -> HelloSheetConfig
  
  fileprivate init(sheet: @MainActor @escaping () -> HelloSheetConfig) {
    self.sheet = sheet
  }
  
  public func action(context: HelloButtonActionContext) async throws {
    guard let windowModel = context.environment[HelloWindowModel.self] else { return }
    let sheet = try await sheet()
    windowModel.present(sheet: sheet)
  }
}

public extension HelloButtonAction where Self == PresentSheetHelloButtonAction {
  static func presentSheet<Content: View>(id: String = String(describing: Content.self),
                                          content: @MainActor @escaping () -> Content) -> PresentSheetHelloButtonAction {
    PresentSheetHelloButtonAction { HelloSheetConfig(id: id, view: content) }
  }
}
#endif
