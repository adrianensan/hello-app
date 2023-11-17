import Foundation
import Combine

import HelloCore

@Observable
public class ActiveThemeManager {
  
  public static let main = ActiveThemeManager()
  
  public private(set) var lightTHeme: HelloTheme = .light
  public private(set) var darkTHeme: HelloTheme = .dark
  
  public func set(theme: some HelloThemeSet) {
    lightTHeme = theme.lightTheme
    darkTHeme = theme.darkTheme
  }
  
  public func set(lightTheme: HelloTheme, darkTheme: HelloTheme) {
    lightTHeme = lightTheme
    darkTHeme = darkTheme
  }
}
