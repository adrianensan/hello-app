import SwiftUI

public enum ButtonHapticsLevel {
  case none
  case onAction
  case onClickAndAction
}

public extension Animation {
  static var button: Animation {
    .spring(response: 0.2, dampingFraction: 0.8, blendDuration: 0.2)
  }
}

public struct HighlightButtonStyle: ButtonStyle {
  
  var highlightAmount: CGFloat = 0.06
  
  #if os(macOS)
  @State var isHovered: Bool = false
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .opacity(isHovered ? 1 - highlightAmount : 1)
      .brightness(configuration.isPressed ? highlightAmount : 0)
      .clickable()
      .onHover { isHovered = $0 }
  }
  #else
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .brightness(configuration.isPressed ? highlightAmount : 0)
      .clickable()
  }
  #endif
}

public extension ButtonStyle where Self == HighlightButtonStyle {
  static var highlight: HighlightButtonStyle { HighlightButtonStyle() }
}

public extension ButtonStyle where Self == HighlightButtonStyle {
  static var deepHighlight: HighlightButtonStyle { HighlightButtonStyle(highlightAmount: 0.16) }
}

public struct NoButtonStyle: ButtonStyle {
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
  }
}

public struct ScaleButtonStyle: ButtonStyle {
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .brightness(configuration.isPressed ? -0.05 : 0)
      .animation(.easeInOut, value: configuration.isPressed)
      .scaleEffect(configuration.isPressed ? 0.95 : 1)
      .animation(.button, value: configuration.isPressed)
      .buttonHaptics(isPressed: configuration.isPressed)
  }
}

public struct SubtleScaleButtonStyle: ButtonStyle {
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .brightness(configuration.isPressed ? -0.04 : 0)
      .animation(.easeInOut, value: configuration.isPressed)
      .scaleEffect(configuration.isPressed ? 0.975 : 1)
      .animation(.button, value: configuration.isPressed)
      .buttonHaptics(isPressed: configuration.isPressed)
  }
}

public struct SubtleButtonStyle: ButtonStyle {
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .brightness(configuration.isPressed ? -0.05 : 0)
      .animation(.easeInOut, value: configuration.isPressed)
      .scaleEffect(configuration.isPressed ? 0.98 : 1)
      .animation(.button, value: configuration.isPressed)
  }
}

public struct HelloButtonStyle: ButtonStyle {
  
  @Environment(\.theme) private var theme
  
  var clickStyle: HelloButtonClickStyle
  var allowHaptics: Bool
  
  public func makeBody(configuration: Configuration) -> some View {
    switch clickStyle {
    case .scale:
      configuration.label
        .brightness(configuration.isPressed ? (theme.theme.isDark ? 1 : -1) * clickStyle.highlightAmount : 0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        .scaleEffect(configuration.isPressed ? clickStyle.scaleAmount : 1)
        .animation(.button, value: configuration.isPressed)
        .buttonHaptics(isPressed: allowHaptics ? configuration.isPressed : false)
    case .highlight:
      configuration.label
        .brightness(configuration.isPressed ? (theme.theme.isDark ? 1 : -1) * clickStyle.highlightAmount : 0)
      //        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
      //        .animation(.button, value: configuration.isPressed)
        .buttonHaptics(isPressed: allowHaptics ? configuration.isPressed : false)
    }
  }
}

public extension ButtonStyle where Self == NoButtonStyle {
  static var noStyle: NoButtonStyle { NoButtonStyle() }
}

public extension ButtonStyle where Self == ScaleButtonStyle {
  static func scale(haptics: ButtonHapticsLevel = .onClickAndAction) -> ScaleButtonStyle {
    ScaleButtonStyle()
  }
}

public extension ButtonStyle where Self == SubtleScaleButtonStyle {
  static var subtleScale: SubtleScaleButtonStyle { SubtleScaleButtonStyle() }
}

public extension ButtonStyle where Self == SubtleButtonStyle {
  static var subtleScaleNoHaptics: SubtleButtonStyle { SubtleButtonStyle() }
}

public extension ButtonStyle where Self == HelloButtonStyle {
  static func hello(clickStyle: HelloButtonClickStyle = .scale ,allowHaptics: Bool) -> HelloButtonStyle {
    HelloButtonStyle(clickStyle: clickStyle, allowHaptics: allowHaptics)
  }
}
