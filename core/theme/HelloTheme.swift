import Foundation

public struct HelloBorder: Codable, Sendable, Hashable {
  public var color: HelloColor
  public var width: CGFloat
  
  public init(color: HelloColor, width: CGFloat = 1) {
    self.color = color
    self.width = width
  }
}

public struct HelloThemeLayer: Codable, Sendable, Hashable {
  
  public var background: HelloBackground
  
  public var foregroundPrimary: HelloFill
  public var foregroundSecondary: HelloFill
  public var foregroundTertiary: HelloFill
  
  public var font: HelloFont
  
  public var accent: HelloFill
  public var disabled: HelloFill
  public var error: HelloFill
  
  public init(background: HelloBackground,
              textPrimary: HelloFill,
              textSecondary: HelloFill,
              textTertiary: HelloFill,
              font: HelloFont,
              accent: HelloFill,
              disabled: HelloFill,
              error: HelloFill) {
    self.background = background
    self.foregroundPrimary = textPrimary
    self.foregroundSecondary = textSecondary
    self.foregroundTertiary = textTertiary
    self.font = font
    self.accent = accent
    self.disabled = disabled
    self.error = error
  }
  
  public init (builder: HelloThemeLayerBuilder?, on underLayer: HelloThemeLayer) {
    let background: HelloBackground
    if let explicitBackground = builder?.background {
      background = explicitBackground
    } else {
      let backgroundColor = underLayer.background.mainColor
      switch underLayer.background {
      case .color, .gradient:
        background = .color(color: .white.withFakeAlpha(0.1, background: backgroundColor),
                            border: HelloBorder(color: backgroundColor.readableOverlayColor.opacity(0.1), width: 1))
      case .blur(let dark, let overlay, let border):
        background = .color(color: .white.opacity(0.2))
      case .image(let helloImageBackground):
        background = .color(color: .white.opacity(0.2))
      }
    }
    let foregroundPrimary = builder?.textPrimary ?? .color(color: background.mainColor.readableOverlayColor.opacity(0.96))
    let foregroundSecondary = builder?.textSecondary ?? .color(color: foregroundPrimary.mainColor.opacity(0.86))
    let foregroundTertiary = builder?.textTertiary ?? .color(color: foregroundSecondary.mainColor.opacity(0.8))
    self.init(background: background,
              textPrimary: foregroundPrimary,
              textSecondary: foregroundSecondary,
              textTertiary: foregroundTertiary,
              font: builder?.font ?? underLayer.font ?? .rounded,
              accent: builder?.accent ?? underLayer.accent,
              disabled: .color(color: .white),
              error: builder?.error ?? underLayer.error)
  }
}
public struct HelloThemeLayerBuilder: Codable, Sendable {
  
  public var background: HelloBackground?
  
  public var textPrimary: HelloFill?
  public var textSecondary: HelloFill?
  public var textTertiary: HelloFill?
  
  public var font: HelloFont?
  
  public var accent: HelloFill?
  public var disabled: HelloFill?
  public var error: HelloFill?
  
  public init(background: HelloBackground? = nil,
              foregroundPrimary: HelloFill? = nil,
              foregroundSecondary: HelloFill? = nil,
              foregroundTertiary: HelloFill? = nil,
              font: HelloFont? = nil,
              accent: HelloFill? = nil,
              disabled: HelloFill? = nil,
              error: HelloFill? = nil) {
    self.background = background
    self.textPrimary = foregroundPrimary
    self.textSecondary = foregroundSecondary
    self.textTertiary = foregroundTertiary
    self.font = font
    self.accent = accent
    self.disabled = disabled
    self.error = error
  }
}

public enum HelloThemeScheme: Codable, Sendable, Equatable {
  case light
  case dark
}

public struct HelloTheme: Codable, Hashable {
  public var id: String
  public var name: String
  
  public var baseLayer: HelloThemeLayer
  public var headerLayer: HelloThemeLayer
  public var floatingLayer: HelloThemeLayer
  public var surfaceLayer: HelloThemeLayer
  public var surfaceSectionLayer: HelloThemeLayer
  
  public init(id: String,
              name: String,
              scheme: HelloThemeScheme,
              baseLayer: HelloThemeLayerBuilder? = nil,
              headerLayer: HelloThemeLayerBuilder? = nil,
              floatingLayer: HelloThemeLayerBuilder? = nil,
              surfaceLayer: HelloThemeLayerBuilder? = nil,
              surfaceSectionLayer: HelloThemeLayerBuilder? = nil) {
    self.id = id
    self.name = name
    do {
      let background = baseLayer?.background ?? (scheme == .light ? HelloTheme.light.baseLayer.background : HelloTheme.dark.baseLayer.background)
      let foregroundPrimary = baseLayer?.textPrimary ?? .color(color: background.mainColor.readableOverlayColor.opacity(0.96))
      let foregroundSecondary = baseLayer?.textSecondary ?? .color(color: foregroundPrimary.mainColor.opacity(0.86))
      let foregroundTertiary = baseLayer?.textTertiary ?? .color(color: foregroundSecondary.mainColor.opacity(0.8))
      self.baseLayer = HelloThemeLayer(background: background,
                                       textPrimary: foregroundPrimary,
                                       textSecondary: foregroundSecondary,
                                       textTertiary: foregroundTertiary,
                                       font: baseLayer?.font ?? .rounded,
                                       accent: baseLayer?.accent ?? .semanticColor(.accent),
                                       disabled: .color(color: .white),
                                       error: baseLayer?.error ?? .semanticColor(.error))
    }
    self.surfaceLayer = .init(builder: surfaceLayer, on: self.baseLayer)
    self.surfaceSectionLayer = .init(builder: surfaceSectionLayer, on: self.surfaceLayer)
    self.headerLayer = .init(builder: headerLayer, on: self.baseLayer)
    self.floatingLayer = .init(builder: floatingLayer, on: self.baseLayer)
  }
  
  public init(id: String,
              name: String,
              baseLayer: HelloThemeLayer,
              headerLayer: HelloThemeLayer,
              floatingLayer: HelloThemeLayer,
              surfaceLayer: HelloThemeLayer,
              surfaceSectionLayer: HelloThemeLayer) {
    self.id = id
    self.name = name
    self.baseLayer = baseLayer
    self.headerLayer = headerLayer
    self.floatingLayer = floatingLayer
    self.surfaceLayer = surfaceLayer
    self.surfaceSectionLayer = surfaceSectionLayer
  }
  
  public var isDark: Bool {
    baseLayer.background.mainColor.isDark
  }
  
  public var isDim: Bool {
    baseLayer.background.mainColor.isDim && baseLayer.foregroundPrimary.mainColor.isDim
  }
  
  public static func simple(
    id: String,
    name: String,
    scheme: HelloThemeScheme,
    accent: HelloFill? = nil,
    background: HelloBackground? = nil,
    headerBackground: HelloBackground? = nil
  ) -> HelloTheme {
    HelloTheme(id: id,
               name: name,
               scheme: scheme,
               baseLayer: HelloThemeLayerBuilder(background: background,
                                                 accent: accent),
               headerLayer: HelloThemeLayerBuilder(background: headerBackground))
  }
}
