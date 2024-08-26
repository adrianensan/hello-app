import SwiftUI

import HelloCore

public struct HelloSwiftUITheme: Sendable {
  
  public enum HelloSwiftUIThemeLayerID: String, Sendable, Identifiable {
    case base
    case surface
    case surfaceSection
    case header
    case floating
    
    public var id: String { rawValue }
  }
  
  public var theme: HelloTheme
  
  @MainActor
  public var backgroundColor: Color { base.backgroundColor }
  
  @MainActor
  public var backgroundView: some View {
    theme.baseLayer.background.view(for: Rectangle())
  }
  
  @MainActor
  public func backgroundView(for shape: some InsettableShape, isBaseLayer: Bool = true) -> some View {
    theme.baseLayer.background.view(for: shape, isBaseLayer: isBaseLayer)
  }
  
  @MainActor
  public func backgroundView(isBaseLayer: Bool = true) -> some View {
    theme.baseLayer.background.view(for: Rectangle(), isBaseLayer: isBaseLayer)
  }
  
  public var backgroundOutline: Color {
    theme.baseLayer.background.borderColor?.swiftuiColor ?? .clear
  }
  
  public var textPrimaryColor: Color { foreground.primary.color }
  public var textSecondaryColor: Color { foreground.secondary.color }
  public var textTertiaryColor: Color { foreground.tertiary.color }
  
  public var accent: HelloSwiftUIThemeForeground { base.accent }
  public var accentColor: Color { accent.color }
  public var accentStyle: AnyShapeStyle { accent.style }
  
  public var error: HelloSwiftUIThemeForeground { base.error }
  
  public var textPrimaryStyle: AnyShapeStyle { foreground.primary.style }
  public var textSecondaryStyle: AnyShapeStyle { foreground.secondary.style }
  public var textTertiaryStyle: AnyShapeStyle { foreground.tertiary.style }

  public var text: HelloSwiftUIThemeForegroundLayers { base.foreground }
  public var foreground: HelloSwiftUIThemeForegroundLayers { base.foreground }
  
  public var base: HelloSwiftUIThemeLayer
  public var surface: HelloSwiftUIThemeLayer
  public var surfaceSection: HelloSwiftUIThemeLayer
  public var surfaceSectionLayer: HelloSwiftUIThemeLayer { surfaceSection }
  public var header: HelloSwiftUIThemeLayer
  public var floating: HelloSwiftUIThemeLayer
  
  public func layer(_ layer: HelloSwiftUIThemeLayerID) -> HelloSwiftUIThemeLayer {
    switch layer {
    case .base: base
    case .surface: surface
    case .surfaceSection: surfaceSection
    case .header: header
    case .floating: floating
    }
  }
  
  public func font(size: CGFloat, weight: Font.Weight) -> Font {
    theme.baseLayer.font.font(size: size, weight: weight)
  }
  
  public var fontDesign: Font.Design? {
    theme.baseLayer.font.fontDesign
  }
  
  public init(theme: HelloTheme) {
    self.theme = theme
    base = HelloSwiftUIThemeLayer(theme: theme.baseLayer)
    surface = HelloSwiftUIThemeLayer(theme: theme.surfaceLayer)
    surfaceSection = HelloSwiftUIThemeLayer(theme: theme.surfaceSectionLayer)
    header = HelloSwiftUIThemeLayer(theme: theme.headerLayer)
    floating = HelloSwiftUIThemeLayer(theme: theme.floatingLayer)
  }
}
