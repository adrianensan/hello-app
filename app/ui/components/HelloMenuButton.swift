#if os(iOS)

import SwiftUI

import HelloCore

public struct HelloMenuButton<Content: View>: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  
  @NonObservedState private var globalFrame: CGRect = .zero
  
  private var clickStyle: HelloButtonClickStyle
  private var items: @MainActor () -> [HelloMenuItem]
  private var content: @MainActor () -> Content
  
  public init(clickStyle: HelloButtonClickStyle = .scale,
              haptics: HapticsType = .click,
              items: @MainActor @escaping () -> [HelloMenuItem],
              @ViewBuilder content: @MainActor @escaping () -> Content) {
    self.clickStyle = clickStyle
    self.items = items
    self.content = content
  }
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, action: {
      windowModel.present {
        HelloMenu(
          position: globalFrame.bottom + CGPoint(x: 0, y: 10),
          anchor: .top,
          items: items())
      }
    }) {
      content()
    }.readFrame(to: $globalFrame)
  }
}
#endif
