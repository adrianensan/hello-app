import SwiftUI

public enum HelloButtonClickStyle {
  case scale
  case highlight
  
  var highlightAmount: CGFloat {
    switch self {
    case .scale:
      -0.05
    case .highlight:
      0.12
    }
  }
  
  var scaleAmount: CGFloat {
    switch self {
    case .scale:
      0.96
    case .highlight:
      1
    }
  }
}

public struct HelloButton<Content: View>: View {
  
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
  
  #if os(macOS)
  @Environment(\.theme) private var theme
  
  @State private var isHovered: Bool = false
  #endif
  
  private var haptics: HapticsType
  private var clickStyle: HelloButtonClickStyle
  private var action: () async throws -> Void
  private var content: Content
  
  public init(clickStyle: HelloButtonClickStyle = .scale,
              haptics: HapticsType = .click,
              action: @escaping () async throws -> Void,
              @ViewBuilder content: () -> Content) {
    self.haptics = haptics
    self.clickStyle = clickStyle
    self.action = action
    self.content = content()
  }
  
  public var body: some View {
    #if os(macOS)
    Button(action: {
      Task {
        try? await Task.sleepForOneFrame()
        try await action()
      }
      if haptics.hapticsOnAction {
        Haptics.buttonFeedback()
      }
    }) {
      content
        .background(theme.foreground.primary.color.opacity(isHovered ? 0.08 : 0))
        .brightness(isHovered ? (theme.theme.isDark ? 1 : -1) * 0.1 : 0)
        .clickable()
    }.buttonStyle(.hello(clickStyle: clickStyle, allowHaptics: haptics.hapticsOnClick))
      .onHover { isHovered = $0 }
      .accessibilityElement()
      .accessibilityAddTraits(.isButton)
    #else
    Button(action: {
      Task {
        try? await Task.sleepForOneFrame()
        try await action()
      }
      if haptics.hapticsOnAction {
        Haptics.buttonFeedback()
      }
    }) {
      content
        .clickable()
    }.buttonStyle(.hello(clickStyle: clickStyle, allowHaptics: haptics.hapticsOnClick))
      .accessibilityElement()
      .accessibilityAddTraits(.isButton)
    #endif
  }
}
