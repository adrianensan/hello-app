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
    layer.background.borderColor?.flattenAlpha(background: layer.background.mainColor).swiftuiColor ?? .clear
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
    
    foreground = HelloSwiftUIThemeForegroundLayers(
      primary: HelloSwiftUIThemeForeground(color: theme.foregroundPrimary.mainColor.swiftuiColor,
                                           style: theme.foregroundPrimary.view),
      secondary: HelloSwiftUIThemeForeground(color: theme.foregroundSecondary.mainColor.swiftuiColor,
                                             style: theme.foregroundSecondary.view),
      tertiary: HelloSwiftUIThemeForeground(color: theme.foregroundTertiary.mainColor.swiftuiColor,
                                            style: theme.foregroundTertiary.view),
      quaternary: HelloSwiftUIThemeForeground(color: theme.foregroundQuaternary.mainColor.swiftuiColor,
                                            style: theme.foregroundQuaternary.view))
    
    accent = HelloSwiftUIThemeForeground(color: theme.accent.mainColor.swiftuiColor,
                                         style: AnyShapeStyle(theme.accent.view))
    
    error = HelloSwiftUIThemeForeground(color: theme.error.mainColor.swiftuiColor,
                                        style: AnyShapeStyle(theme.error.view))
  }
}
