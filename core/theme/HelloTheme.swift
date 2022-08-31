import Foundation

public struct HelloBorder: Codable {
  public var color: HelloColor
  public var width: CGFloat
  
  public init(color: HelloColor, width: CGFloat = 1) {
    self.color = color
    self.width = width
  }
}

public struct HelloThemeLayer: Codable {
  
  public var background: HelloBackground?
  
  public var textPrimary: HelloFill?
  public var textSecondary: HelloFill?
  public var textTertiary: HelloFill?
  
  public var accent: HelloFill?
  public var disabled: HelloFill?
  public var error: HelloFill?
  
  public init(background: HelloBackground? = nil,
              textPrimary: HelloFill? = nil,
              textSecondary: HelloFill? = nil,
              textTertiary: HelloFill? = nil,
              accent: HelloFill? = nil,
              disabled: HelloFill? = nil,
              error: HelloFill? = nil) {
    self.background = background
    self.textPrimary = textPrimary
    self.textSecondary = textSecondary
    self.textTertiary = textTertiary
    self.accent = accent
    self.disabled = disabled
    self.error = error
  }
  
  public init(backgroundColor: HelloColor? = nil,
              backgroundBorder: HelloBorder? = nil,
              textPrimaryColor: HelloColor? = nil,
              textSecondaryColor: HelloColor? = nil,
              textTertiaryColor: HelloColor? = nil,
              accentColor: HelloColor? = nil,
              disabledColor: HelloColor? = nil,
              errorColor: HelloColor? = nil) {
    if let backgroundColor {
      self.background = .color(color: backgroundColor, border: backgroundBorder)
    }
    if let textPrimaryColor {
      self.textPrimary = .color(color: textPrimaryColor)
    }
    if let textSecondaryColor {
      self.textSecondary = .color(color: textSecondaryColor)
    }
    if let textTertiaryColor {
      self.textTertiary = .color(color: textTertiaryColor)
    }
    if let accentColor {
      self.accent = .color(color: accentColor)
    }
    if let disabledColor {
      self.disabled = .color(color: disabledColor)
    }
    if let errorColor {
      self.error = .color(color: errorColor)
    }
  }
}

public struct HelloTheme: Codable {
  public var id: String
  public var name: String
  
  public var baseLayer: HelloThemeLayer
  public var headerLayer: HelloThemeLayer?
  public var floatingLayer: HelloThemeLayer?
  public var additionalLayers: [Int: HelloThemeLayer]
  
  public init(id: String,
              name: String,
              baseLayer: HelloThemeLayer,
              headerLayer: HelloThemeLayer? = nil,
              floatingLayer: HelloThemeLayer? = nil,
              additionalLayers: [Int : HelloThemeLayer] = [:]) {
    self.id = id
    self.name = name
    self.baseLayer = baseLayer
    self.headerLayer = headerLayer
    self.floatingLayer = floatingLayer
    self.additionalLayers = additionalLayers
  }
}
