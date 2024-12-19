import SwiftUI

import HelloCore

public struct MenuHelloButtonAction: HelloButtonAction {
  
  private var menuItems: @MainActor () async throws -> [HelloMenuItem]
  
  fileprivate init(menuItems: @MainActor @escaping () async throws -> [HelloMenuItem]) {
    self.menuItems = menuItems
  }
  
  public func action(context: HelloButtonActionContext) async throws {
    guard let windowModel = context.environment[HelloWindowModel.self] else { return }
    let menuItems = try await menuItems()
    windowModel.present {
      HelloMenu(
        position: context.buttonFrame.bottom + CGPoint(x: 0, y: 10),
        anchor: .top,
        items: menuItems)
    }
  }
}

public extension HelloButtonAction where Self == MenuHelloButtonAction {
  static func showMenu(_ menuItems: @MainActor @escaping () async throws -> [HelloMenuItem]) -> MenuHelloButtonAction {
    MenuHelloButtonAction(menuItems: menuItems)
  }
}
