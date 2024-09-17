import SwiftUI

import HelloCore

public struct HelloButtonStyle: ButtonStyle {
  
  @Environment(\.theme) private var theme
  @Environment(\.contentShape) private var contentShape
  @Environment(\.isEnabled) private var isEnabled
  @Environment(HelloButtonModel.self) private var model
  
  @State private var isPressed: Bool = false
  
  var clickStyle: HelloButtonClickStyle
  
  public func makeBody(configuration: Configuration) -> some View {
    Group {
      switch clickStyle {
      case .scale:
        configuration.label
          .brightness(isPressed ? (theme.theme.isDark ? 1 : -1) * clickStyle.highlightAmount : 0)
          .animation(.easeInOut(duration: 0.1), value: isPressed)
          .scaleEffect(isPressed ? clickStyle.scaleAmount : 1)
          .animation(.button, value: isPressed)
      case .highlight:
        configuration.label
          .brightness(isPressed ? (theme.theme.isDark ? 1 : -1) * clickStyle.highlightAmount : 0)
        //        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        //        .animation(.button, value: configuration.isPressed)
          .background(contentShape?.fill(Color(hue: 0, saturation: 0, brightness: (theme.theme.isDark ? 1 : 0), opacity: isPressed ? 0.1 : 0)))
          .animation(isPressed ? nil : .easeInOut(duration: 0.2), value: isPressed)
      }
    }.onChange(of: configuration.isPressed) {
      isPressed = isEnabled && configuration.isPressed
      if isPressed {
        if !model.hasPressed && model.hapticsType.hapticsOnClick {
          ButtonHaptics.buttonFeedback()
        }
        model.hasPressed = true
      } else {
        Task {
          try await Task.sleepForABit()
          model.hasPressed = false
        }
      }
    }.onChange(of: model.forceVisualPress) {
      guard isPressed != model.forceVisualPress else { return }
      isPressed = model.forceVisualPress
    }.onChange(of: isEnabled) {
      if !isEnabled && isPressed {
        isPressed = false
      }
    }
  }
}

public extension ButtonStyle where Self == HelloButtonStyle {
  static func hello(clickStyle: HelloButtonClickStyle = .scale) -> HelloButtonStyle {
    HelloButtonStyle(clickStyle: clickStyle)
  }
}

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

@MainActor
@Observable
fileprivate class HelloButtonModel {
  var hapticsType: HapticsType
  var forceVisualPress: Bool = false
  @ObservationIgnored var hasPressed: Bool = false
  @ObservationIgnored var hasClicked: Bool = false
  
  init(hapticsType: HapticsType) {
    self.hapticsType = hapticsType
  }
}

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

public struct HelloShareLink<Content: View>: View {
  
  @State private var model: HelloButtonModel
  
  private var url: URL
  private var clickStyle: HelloButtonClickStyle
  private var content: @MainActor () -> Content
  
  public init(url: URL,
              clickStyle: HelloButtonClickStyle = .scale,
              haptics: HapticsType = .click,
              @ViewBuilder content: @MainActor @escaping () -> Content) {
    self.url = url
    self.clickStyle = clickStyle
    self.content = content
    _model = State(initialValue: HelloButtonModel(hapticsType: haptics))
  }
  
  public var body: some View {
    ShareLink(item: url) {
      content()
        .clickable()
    }.buttonStyle(.hello(clickStyle: clickStyle))
      .accessibilityElement()
      .accessibilityAddTraits(.isButton)
      .environment(model)
  }
}

public struct HelloButton<Content: View>: View {
  
  #if os(macOS)
  @Environment(\.theme) private var theme
  @Environment(\.contentShape) private var contentShape
  
  @State private var isHovered: Bool = false
  #endif
  
  @State private var model: HelloButtonModel
  
  private var clickStyle: HelloButtonClickStyle
  private var action: @MainActor () async throws -> Void
  private var content: @MainActor () -> Content
  
  public init(clickStyle: HelloButtonClickStyle = .scale,
              haptics: HapticsType = .click,
              action: @MainActor @escaping () async throws -> Void,
              @ViewBuilder content: @MainActor @escaping () -> Content) {
    self.clickStyle = clickStyle
    self.action = action
    self.content = content
    _model = State(initialValue: HelloButtonModel(hapticsType: haptics))
  }
  
  public var body: some View {
    #if os(macOS)
    Button(action: {
      guard !model.hasClicked else { return }
      model.hasClicked = true
      Task {
        try? await Task.sleepForOneFrame()
        try await action()
        model.hasClicked = false
      }
    }) {
      content()
        .background(contentShape?.fill(theme.foreground.primary.style.opacity(isHovered ? 0.08 : 0)))
        .brightness(isHovered ? (theme.theme.isDark ? 1 : -1) * 0.1 : 0)
        .clickable()
    }.buttonStyle(.hello(clickStyle: clickStyle))
      .onHover { isHovered = $0 }
      .accessibilityElement()
      .accessibilityAddTraits(.isButton)
      .environment(model)
    #else
    Button(action: {
      guard !model.hasClicked else { return }
      model.hasClicked = true
      Task {
        defer { model.hasClicked = false }
        Task {
          try? await Task.sleepForOneFrame()
          model.hasPressed = false
          model.forceVisualPress = false
        }
        try await action()
      }
      model.forceVisualPress = true
      if model.hapticsType.hapticsOnAction {
        Haptics.buttonFeedback()
      } else if !model.hasPressed && model.hapticsType == .click {
        model.hasPressed = true
        Haptics.buttonFeedback()
      }
    }) {
      content()
        .clickable()
    }.buttonStyle(.hello(clickStyle: clickStyle))
      .accessibilityElement()
      .accessibilityAddTraits(.isButton)
      .environment(model)
    #endif
  }
}
