import Foundation
import SwiftUI

import HelloCore

@MainActor
@Observable
public class ActiveThemeManager {
  
  public static let main = ActiveThemeManager()
  
  public private(set) var lightTheme: HelloTheme = .light
  public private(set) var darkTheme: HelloTheme = .dark
  
  public private(set) var isDark: Bool = true
  public private(set) var isLowBrightness: Bool = UIScreen.main.brightness < 0.08
  
  private var themeMode = Persistence.model(for: .themeMode)
  private var accentColor = Persistence.model(for: .accentColor)
  private var useBarelyVisibleThemeWhenDark = Persistence.model(for: .useBarelyVisibleThemeWhenDark)
  
  private init() {
    Task {
      for await notification in NotificationCenter.default.notifications(named: UIScreen.brightnessDidChangeNotification) {
        Task {
          let isLowBrightness = UIScreen.main.brightness < 0.08
          guard self.isLowBrightness != isLowBrightness else { return }
          self.isLowBrightness = isLowBrightness
        }
      }
    }
  }
  
  public func set(theme: some HelloThemeSet) {
    lightTheme = theme.lightTheme
    darkTheme = theme.darkTheme
  }
  
  public func set(lightTheme: HelloTheme, darkTheme: HelloTheme) {
    self.lightTheme = lightTheme
    self.darkTheme = darkTheme
  }
  
  public func activeTheme(isDark: Bool) -> HelloTheme {
    var isDark = isDark
    switch themeMode.value {
    case .auto: ()
    case .alwaysLight:
      isDark = false
    case .alwaysDark:
      isDark = true
    }
    if self.isDark != isDark {
      self.isDark = isDark
    }
    if isDark {
      if useBarelyVisibleThemeWhenDark.value && isLowBrightness {
        return .superBlack(accent: accentColor.value)
      } else {
        return darkTheme
      }
    } else {
      return lightTheme
    }
  }
}
