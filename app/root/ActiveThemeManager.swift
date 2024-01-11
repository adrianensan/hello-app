import Foundation
import Combine

import HelloCore

@MainActor
@Observable
public class ActiveThemeManager {
  
  public static let main = ActiveThemeManager()
  
  public private(set) var lightTheme: HelloTheme = .light
  public private(set) var darkTheme: HelloTheme = .dark
  
  public func set(theme: some HelloThemeSet) {
    lightTheme = theme.lightTheme
    darkTheme = theme.darkTheme
  }
  
  public func set(lightTheme: HelloTheme, darkTheme: HelloTheme) {
    self.lightTheme = lightTheme
    self.darkTheme = darkTheme
  }
}
