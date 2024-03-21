import SwiftUI

public struct BasicHelloButton<Content: View>: View {
  
  public enum HapticsType {
    case none
    case action
    case clickAndAction
    case click
    
    var hapticsOnClick: Bool {
      switch self {
      case .none:
        false
      case .action:
        false
      case .clickAndAction:
        true
      case .click:
        true
      }
    }
    
    var hapticsOnAction: Bool {
      switch self {
      case .none:
        false
      case .action:
        true
      case .clickAndAction:
        true
      case .click:
        false
      }
    }
  }
  
  private var haptics: HapticsType
  private var action: () -> Void
  private var content: Content
  
  public init(haptics: HapticsType = .clickAndAction, 
              action: @escaping () -> Void,
              @ViewBuilder content: () -> Content) {
    self.haptics = haptics
    self.action = action
    self.content = content()
  }
  
  public var body: some View {
    Button(action: {
      action()
      if haptics.hapticsOnAction {
        Haptics.buttonFeedback()
      }
    }) {
      content
    }.buttonStyle(.hello(allowHaptics: haptics.hapticsOnClick))
      .accessibilityElement()
      .accessibilityAddTraits(.isButton)
  }
}
