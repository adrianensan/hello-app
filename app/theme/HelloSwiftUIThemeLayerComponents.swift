import SwiftUI

public struct HelloSwiftUIThemeBackground: Sendable {
  public var color: Color
  public var style: AnyShapeStyle
}

public struct HelloSwiftUIThemeForeground: Sendable {
  public var color: Color
  public var style: AnyShapeStyle
}

public struct HelloSwiftUIThemeForegroundLayers: Sendable {
  public var primary: HelloSwiftUIThemeForeground
  public var secondary: HelloSwiftUIThemeForeground
  public var tertiary: HelloSwiftUIThemeForeground
  public var quaternary: HelloSwiftUIThemeForeground
}
