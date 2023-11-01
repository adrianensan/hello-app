import SwiftUI

import HelloCore

public struct HelloSwiftUIThemeLayer {
  
  let layer: HelloThemeLayer
  
  public var backgroundView: some View {
    layer.background.view(for: Rectangle(), isBaseLayer: true)
  }
  
  public func backgroundView(for shape: some Shape, isBaseLayer: Bool = false) -> some View {
    layer.background.view(for: shape, isBaseLayer: isBaseLayer)
  }
  
  public func backgroundView(isBaseLayer: Bool = true) -> some View {
    layer.background.view(for: Rectangle(), isBaseLayer: isBaseLayer)
  }
  
  public var backgroundColor: Color
  public var foreground: HelloSwiftUIThemeForegroundLayers
  public var accent: HelloSwiftUIThemeForeground
  public var error: HelloSwiftUIThemeForeground
  
  public func font(size: CGFloat, weight: Font.Weight) -> Font {
    layer.font.font(size: size, weight: weight)
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
                                            style: theme.foregroundTertiary.view))
    
    accent = HelloSwiftUIThemeForeground(color: theme.accent.mainColor.swiftuiColor,
                                         style: AnyShapeStyle(theme.accent.view))
    
    error = HelloSwiftUIThemeForeground(color: theme.error.mainColor.swiftuiColor,
                                        style: AnyShapeStyle(theme.error.view))
  }
}
