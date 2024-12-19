import SwiftUI

import HelloCore

public struct HelloButtonStyle: ButtonStyle {
  
  @Environment(\.theme) private var theme
  @Environment(\.viewShape) private var viewShape
  @Environment(\.isEnabled) private var isEnabled
  @Environment(HelloButtonModel.self) private var model
  
  @State private var isPressed: Bool = false
  @State private var isHovered: Bool = false
  
  var clickStyle: HelloButtonClickStyle
  var longPressAction: (@MainActor () async throws -> Void)?
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .background(isHovered ? viewShape.fill((theme.theme.isDark ? Color.white : Color.black).opacity(0.08)) : nil)
      .brightness(isHovered ? (theme.theme.isDark ? 1 : -1) * 0.08 : 0)
      .brightness(isPressed ? (theme.theme.isDark ? 1 : -1) * 0.12 : 0)
      .animation(.easeInOut(duration: 0.1), value: isPressed)
      .scaleEffect(isPressed ? clickStyle.scaleAmount : 1)
      .animation(.spring(dampingFraction: 0.6).speed(1.6), value: isPressed)
      .onHover { isHovered = $0 }
      .onChange(of: configuration.isPressed) {
        isPressed = isEnabled && configuration.isPressed
        if isPressed {
          if longPressAction != nil {
            model.longPressTask?.cancel()
            model.longPressTask = Task {
              try await Task.sleep(seconds: 0.4)
              ButtonHaptics.buttonFeedback()
              Task { try await longPressAction?() }
              model.longPressTask = nil
            }
          }
          if !model.hasPressed {
            ButtonHaptics.buttonFeedback()
          }
          model.hasPressed = true
        } else {
          model.longPressTask?.cancel()
          model.longPressTask = nil
          Task {
            try await Task.sleepForABit()
            model.hasPressed = false
          }
        }
      }.onChange(of: model.forceVisualPress) {
        guard isPressed != model.forceVisualPress else { return }
        isPressed = model.forceVisualPress
      }.when(!isEnabled && isPressed) {
        isPressed = false
        model.longPressTask?.cancel()
        model.longPressTask = nil
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
  
  public static var `default`: HelloButtonClickStyle {
#if os(iOS)
    .scale
#elseif os(macOS)
    .highlight
#endif
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
  var forceVisualPress: Bool = false
  @ObservationIgnored var longPressTask: Task<Void, any Error>?
  @ObservationIgnored var hasPressed: Bool = false
  @ObservationIgnored var hasClicked: Bool = false
  
  init() {
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

/// SwiftUI Button with an async throws action, haptics, and fully customizable label
public struct HelloButton<Content: View>: View {
  
#if os(macOS)
  @Environment(\.theme) private var theme
  @Environment(\.contentShape) private var contentShape
  
  @State private var isHovered: Bool = false
#endif
  
  @Environment(\.all) private var all
  
  @State private var model: HelloButtonModel
  
  @NonObservedState private var globalFrame: CGRect = .zero
  
  private var clickStyle: HelloButtonClickStyle
  private var action: (any HelloButtonAction)?
  private var longPressAction: (any HelloButtonAction)?
  private var content: @MainActor () -> Content
  
  public init(clickStyle: HelloButtonClickStyle = .default,
              action: some HelloButtonAction,
              longPressAction: some HelloButtonAction,
              @ViewBuilder content: @MainActor @escaping () -> Content) {
    self.clickStyle = clickStyle
    self.content = content
    self.action = action
    self.longPressAction = longPressAction
    _model = State(initialValue: HelloButtonModel())
  }
  
  public init(clickStyle: HelloButtonClickStyle = .default,
              tapAndLongPressAction: some HelloButtonAction,
              @ViewBuilder content: @MainActor @escaping () -> Content) {
    self.clickStyle = clickStyle
    self.content = content
    self.action = tapAndLongPressAction
    self.longPressAction = tapAndLongPressAction
    _model = State(initialValue: HelloButtonModel())
  }
  
  public init(clickStyle: HelloButtonClickStyle = .default,
              action: some HelloButtonAction,
              @ViewBuilder content: @MainActor @escaping () -> Content) {
    self.clickStyle = clickStyle
    self.content = content
    self.action = action
    self.longPressAction = nil
    _model = State(initialValue: HelloButtonModel())
  }
  
  public init(clickStyle: HelloButtonClickStyle = .default,
              action: @MainActor @escaping () async throws -> Void,
              longPressAction: some HelloButtonAction,
              @ViewBuilder content: @MainActor @escaping () -> Content) {
    self.clickStyle = clickStyle
    self.content = content
    self.action = .closure(action)
    self.longPressAction = longPressAction
    _model = State(initialValue: HelloButtonModel())
  }
  
  public init(clickStyle: HelloButtonClickStyle = .default,
              action: @MainActor @escaping () async throws -> Void,
              @ViewBuilder content: @MainActor @escaping () -> Content) {
    self.clickStyle = clickStyle
    self.content = content
    self.action = .closure(action)
    self.longPressAction = nil
    _model = State(initialValue: HelloButtonModel())
  }
  
  public init(clickStyle: HelloButtonClickStyle = .default,
              action: @MainActor @escaping () async throws -> Void,
              longPressAction: @MainActor @escaping () async throws -> Void,
              @ViewBuilder content: @MainActor @escaping () -> Content) {
    self.clickStyle = clickStyle
    self.content = content
    self.action = .closure(action)
    self.longPressAction = .closure(action)
    _model = State(initialValue: HelloButtonModel())
  }
  
  public init(clickStyle: HelloButtonClickStyle = .default,
              tapAndlongPressAction: @MainActor @escaping () async throws -> Void,
              @ViewBuilder content: @MainActor @escaping () -> Content) {
    self.clickStyle = clickStyle
    self.content = content
    self.action = .closure(tapAndlongPressAction)
    self.longPressAction = .closure(tapAndlongPressAction)
    _model = State(initialValue: HelloButtonModel())
  }
  
  private var context: HelloButtonActionContext {
    HelloButtonActionContext(
      environment: all,
      buttonFrame: globalFrame)
  }
  
  public var body: some View {
#if os(macOS)
    Button(action: {
      guard !model.hasClicked else { return }
      model.hasClicked = true
      Task {
        try? await Task.sleepForOneFrame()
        try await action?()
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
        try await action?.action(context: context)
      }
      model.forceVisualPress = true
      if !model.hasPressed {
        model.hasPressed = true
        Haptics.buttonFeedback()
      }
    }) {
      content()
        .clickable()
    }.buttonStyle(HelloButtonStyle(
      clickStyle: clickStyle,
      longPressAction: longPressAction.flatMap { action in { try await action.action(context: context) } }))
    .accessibilityElement()
    .accessibilityAddTraits(.isButton)
    .environment(model)
    .readFrame(to: $globalFrame)
#endif
  }
}
