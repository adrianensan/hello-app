import SwiftUI

public struct HelloSwiftUIThemeBackground {
  public var color: Color
  public var style: AnyShapeStyle
}

public struct HelloSwiftUIThemeForeground {
  public var color: Color
  public var style: AnyShapeStyle
}

public struct HelloSwiftUIThemeForegroundLayers {
  public var primary: HelloSwiftUIThemeForeground
  public var secondary: HelloSwiftUIThemeForeground
  public var tertiary: HelloSwiftUIThemeForeground
}
