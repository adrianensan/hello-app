import Foundation

public struct HelloThemeContext {
  
  public enum Layer: Hashable {
    case layer(Int)
    case header
    case floating
  }
  
  public enum LayerChange {
    case base
    case raised
    case lowered
    case header
    case floating
  }
  
  private var theme: HelloTheme
  private var layer: Layer
  
  public var background: HelloBackground
  
  public var textPrimary: HelloFill
  public var textSecondary: HelloFill
  public var textTertiary: HelloFill
  
  public var accent: HelloFill
  public var disabled: HelloFill
  public var error: HelloFill
  
  public init(theme: HelloTheme, layer: Layer = .layer(0)) {
    self.theme = theme
    self.layer = layer
    
    let baseTheme = theme.baseLayer
    
    let background = baseTheme.background ?? .color(color: HelloColor(r: 0.1, g: 0.1, b: 0.1))
    let textPrimary = baseTheme.textPrimary ?? .color(color: background.mainColor.readableOverlayColor.opacity(0.9))
    let textSecondary = baseTheme.textPrimary ?? .color(color: textPrimary.mainColor.opacity(0.72))
    let textTertiary = baseTheme.textTertiary ?? .color(color: textSecondary.mainColor.opacity(0.6))
    
    self.background = background
    
    self.textPrimary = textPrimary
    self.textSecondary = textSecondary
    self.textTertiary = textTertiary

    self.accent = baseTheme.accent ?? .color(color: HelloColor(r: 0.43, g: 0.725, b: 0.98))
    self.disabled = baseTheme.disabled ?? .color(color: textPrimary.mainColor.opacity(0.3))
    self.error = baseTheme.error ?? .color(color: HelloColor(r: 0.9, g: 0, b: 0))
  }
  
//  var style: AnyShapeStyle {
//    switch accent {
//    case .color(let color):
//      return AnyShapeStyle(color.swiftuiColor)
//    case .gradient(let helloGradient):
//      return AnyShapeStyle(LinearGradient(colors: [], startPoint: .top, endPoint: .bottom))
//    }
//  }
  
  func context(for layerChange: LayerChange) -> HelloThemeContext {
    switch layerChange {
    case .base:
      return HelloThemeContext(theme: theme, layer: .layer(0))
    case .raised:
      switch layer {
      case .layer(let layer): return HelloThemeContext(theme: theme, layer: .layer(layer + 1))
      default: return HelloThemeContext(theme: theme, layer: .layer(2))
      }
    case .lowered:
      switch layer {
      case .layer(let layer): return HelloThemeContext(theme: theme, layer: .layer(layer - 1))
      default: return HelloThemeContext(theme: theme, layer: .layer(0))
      }
    case .header:
      return HelloThemeContext(theme: theme, layer: .header)
    case .floating:
      return HelloThemeContext(theme: theme, layer: .floating)
    }
  }
  
  
}
