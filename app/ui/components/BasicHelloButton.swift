import SwiftUI

public struct BasicHelloButton<Content: View>: View {
  
  public enum HapticsType {
    case none
    case action
    case clickAndAction
  }
  
  private var haptics: HapticsType
  private var action: () -> Void
  private var content: Content
  
  public init(haptics: HapticsType = .clickAndAction, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
    self.haptics = haptics
    self.action = action
    self.content = content()
  }
  
  public var body: some View {
    Button(action: {
      action()
      if haptics != .none {
        Haptics.buttonFeedback()
      }
    }) {
      content
    }.buttonStyle(.hello(allowHaptics: haptics == .clickAndAction))
      .accessibilityElement()
      .accessibilityAddTraits(.isButton)
  }
}
