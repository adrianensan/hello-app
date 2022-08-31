import SwiftUI

import HelloCore

public struct HelloSwiftUITheme {
  
  public var theme: HelloThemeContext
  
  public var backgroundColor: Color
  public var backgroundView: some View {
    theme.background.view(for: RoundedRectangle(cornerRadius: 8, style: .continuous))
  }
  
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
    
    textPrimaryColor = theme.textPrimary.mainColor.swiftuiColor
    textSecondaryColor = theme.textSecondary.mainColor.swiftuiColor
    textTertiaryColor = theme.textTertiary.mainColor.swiftuiColor
    
    accentColor = theme.accent.mainColor.swiftuiColor
    accentStyle = AnyShapeStyle(theme.accent.view)
    
    textPrimaryStyle = AnyShapeStyle(theme.textPrimary.view)
    textSecondaryStyle = AnyShapeStyle(theme.textSecondary.view)
    textTertiaryStyle = AnyShapeStyle(theme.textTertiary.view)
  }
}
