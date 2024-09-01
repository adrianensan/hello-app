import SwiftUI

import HelloCore

public struct HelloPickerPopupItem: Identifiable {
  public var id: String
  var name: String
  var action: @MainActor () async throws -> Void
  
  public init(id: String = .uuid,
              name: String,
              action: @MainActor @escaping () async throws -> Void) {
    self.id = id
    self.name = name
    self.action = action
  }
}
