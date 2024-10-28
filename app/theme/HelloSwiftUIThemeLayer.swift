import SwiftUI

import HelloCore

public struct HelloSwiftUIThemeLayer: Sendable {
  
  let layer: HelloThemeLayer
  
  @MainActor
  public var backgroundView: some View {
    layer.background.view(for: Rectangle(), isBaseLayer: true)
  }
  
  @MainActor
  public func backgroundView(for shape: some InsettableShape, isBaseLayer: Bool = false) -> some View {
    layer.background.view(for: shape, isBaseLayer: isBaseLayer)
  }
  
  @MainActor
  public func backgroundView(isBaseLayer: Bool = true) -> some View {
    layer.background.view(for: Rectangle(), isBaseLayer: isBaseLayer)
  }
  
  public var backgroundOutlineWidth: CGFloat {
    layer.background.borderWidth ?? 0
  }
  
  public var backgroundOutline: Color {
    if case .blur = layer.background {
      layer.background.borderColor?.swiftuiColor ?? .clear
    } else if layer.background.mainColor.alpha < 0.4 {
      layer.background.borderColor?.swiftuiColor ?? .clear
    } else {
      layer.background.borderColor?.flattenAlpha(background: layer.background.mainColor).swiftuiColor ?? .clear
    }
  }
  
  public var backgroundColor: Color
  public var foreground: HelloSwiftUIThemeForegroundLayers
  public var accent: HelloSwiftUIThemeForeground
  public var error: HelloSwiftUIThemeForeground
  
  public var divider: HelloBorder {
    if case .color(_, let border) = layer.background, let border {
      border
    } else {
      HelloBorder(color: layer.foregroundPrimary.mainColor.opacity(0.12), width: 1)
    }
  }
  
  public func font(size: CGFloat, weight: Font.Weight) -> Font {
    layer.font.font(size: size, weight: weight)
  }
  
  public var fontDesign: Font.Design? {
    layer.font.fontDesign
  }
  
  public init(theme: HelloThemeLayer) {
    self.layer = theme
    
    backgroundColor = theme.background.mainColor.swiftuiColor
    
    let isDim = theme.background.mainColor.isDim && theme.foregroundPrimary.mainColor.isDim
    foreground = HelloSwiftUIThemeForegroundLayers(
      primary: HelloSwiftUIThemeForeground(
        color: theme.foregroundPrimary.mainColor.swiftuiColor,
        style: theme.foregroundPrimary.view,
        readableOverlayColor: theme.foregroundPrimary.mainColor.readableOverlayColor.swiftuiColor.opacity(isDim ? 0.5 : 1)),
      secondary: HelloSwiftUIThemeForeground(
        color: theme.foregroundSecondary.mainColor.swiftuiColor,
        style: theme.foregroundSecondary.view,
        readableOverlayColor: theme.foregroundSecondary.mainColor.readableOverlayColor.swiftuiColor.opacity(isDim ? 0.5 : 1)),
      tertiary: HelloSwiftUIThemeForeground(
        color: theme.foregroundTertiary.mainColor.swiftuiColor,
        style: theme.foregroundTertiary.view,
        readableOverlayColor: theme.foregroundTertiary.mainColor.readableOverlayColor.swiftuiColor.opacity(isDim ? 0.5 : 1)),
      quaternary: HelloSwiftUIThemeForeground(
        color: theme.foregroundQuaternary.mainColor.swiftuiColor,
        style: theme.foregroundQuaternary.view,
        readableOverlayColor: theme.foregroundQuaternary.mainColor.readableOverlayColor.swiftuiColor.opacity(isDim ? 0.5 : 1)))
    
    accent = HelloSwiftUIThemeForeground(
      color: theme.accent.mainColor.swiftuiColor,
      style: AnyShapeStyle(theme.accent.view),
      readableOverlayColor: theme.accent.mainColor.readableOverlayColor.swiftuiColor.opacity(isDim ? 0.5 : 1))
    
    error = HelloSwiftUIThemeForeground(
      color: theme.error.mainColor.swiftuiColor,
      style: AnyShapeStyle(theme.error.view),
      readableOverlayColor: theme.error.mainColor.readableOverlayColor.swiftuiColor.opacity(isDim ? 0.5 : 1))
  }
}
