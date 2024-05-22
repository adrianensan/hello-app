import SwiftUI

import HelloCore

@MainActor
struct WindowFrameObservationViewModifier: ViewModifier {
  
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(UIProperties.self) private var uiProperties
  
  func body(content: Content) -> some View {
    content
      .environment(\.windowFrame, windowModel.window?.frame ?? CGRect(origin: .zero, size: uiProperties.size))
  }
}

@MainActor
public extension View {
  func observeWindowFrame() -> some View {
    modifier(WindowFrameObservationViewModifier())
  }
}
