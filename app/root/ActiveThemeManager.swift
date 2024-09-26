import Foundation
import SwiftUI

import HelloCore

@MainActor
@Observable
public class ActiveThemeManager {
  
  public static let main = ActiveThemeManager()
  
  private static var isLowBrightness: Bool {
    #if os(iOS)
    UIScreen.main.brightness < 0.08
    #elseif os(macOS)
    false
    #else
    #endif
  }
  
  public private(set) var lightTheme: HelloTheme = .helloLight
  public private(set) var darkTheme: HelloTheme = .helloDark
  
  public private(set) var colorScehem: HelloThemeScheme = .light
  public private(set) var isLowBrightness: Bool = isLowBrightness
  
  private var themeMode = Persistence.model(for: .themeMode)
  private var accentColor = Persistence.model(for: .accentColor)
  private var useBarelyVisibleThemeWhenDark = Persistence.model(for: .useBarelyVisibleThemeWhenDark)
  
  private init() {
    #if os(iOS)
    Task {
      for await notification in NotificationCenter.default.notifications(named: UIScreen.brightnessDidChangeNotification) {
        Task {
          let isLowBrightness = Self.isLowBrightness
          guard self.isLowBrightness != isLowBrightness else { return }
          self.isLowBrightness = isLowBrightness
        }
      }
    }
    #endif
  }
  
  public func set(theme: some HelloThemeSet) {
    lightTheme = theme.lightTheme
    darkTheme = theme.darkTheme
  }
  
  public func set(lightTheme: HelloTheme, darkTheme: HelloTheme) {
    self.lightTheme = lightTheme
    self.darkTheme = darkTheme
  }
  
  public func activeTheme(for colorScheme: HelloThemeScheme) -> HelloTheme {
    var colorScheme = colorScheme
    switch themeMode.value {
    case .auto: ()
    case .alwaysLight:
      colorScheme = .light
    case .alwaysDark:
      colorScheme = .dark
    }
    if self.colorScehem != colorScheme {
      self.colorScehem = colorScheme
    }
    switch colorScheme {
    case .light:
      return lightTheme
    case .dark:
      if useBarelyVisibleThemeWhenDark.value && isLowBrightness {
        return .superBlack(accent: accentColor.value)
      } else {
        return darkTheme
      }
    }
  }
}
