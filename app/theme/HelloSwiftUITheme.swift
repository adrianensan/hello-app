import SwiftUI

import HelloCore

public struct HelloSwiftUITheme {
  
  public var theme: HelloThemeContext
  
  public var backgroundColor: Color
//  public var backgroundView: AnyView
  
  public var textPrimaryColor: Color
  public var textSecondaryColor: Color
  public var textTertiaryColor: Color
  
  public var accentColor: Color
  public var accentStyle: AnyShapeStyle
  
  public var textPrimaryStyle: AnyShapeStyle
  public var textSecondaryStyle: AnyShapeStyle
  public var textTertiaryStyle: AnyShapeStyle
  
  public init(theme: HelloThemeContext) {
    self.theme = theme
    
    backgroundColor = theme.background.mainColor.swiftuiColor
    //backgroundView = theme.background.
    
    textPrimaryColor = theme.textPrimary.mainColor.swiftuiColor
    textSecondaryColor = theme.textSecondary.mainColor.swiftuiColor
    textTertiaryColor = theme.textTertiary.mainColor.swiftuiColor
    
    accentColor = theme.accent.mainColor.swiftuiColor
    accentStyle = AnyShapeStyle(theme.accent.mainColor.swiftuiColor)
    
    textPrimaryStyle = AnyShapeStyle(theme.textPrimary.mainColor.swiftuiColor)
    textSecondaryStyle = AnyShapeStyle(theme.textSecondary.mainColor.swiftuiColor)
    textTertiaryStyle = AnyShapeStyle(theme.textTertiary.mainColor.swiftuiColor)
  }
}
