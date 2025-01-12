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
  
  public private(set) var colorScheme: HelloThemeScheme = .light
  public private(set) var isLowBrightness: Bool = isLowBrightness
  
  private var _themeMode = Persistence.model(for: .themeMode)
  private var themeMode: ThemeMode { _themeMode.value }
  
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
  
  public var effectiveColorScheme: HelloThemeScheme { themeMode.effectiveScheme(for: colorScheme) }
  
  public var activeTheme: HelloTheme {
    switch effectiveColorScheme {
    case .light: lightTheme
    case .dark:
      if useBarelyVisibleThemeWhenDark.value && isLowBrightness {
        .superBlack(accent: accentColor.value)
      } else {
        darkTheme
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
  
  public func set(colorScheme: HelloThemeScheme) {
    guard self.colorScheme != colorScheme else { return }
    self.colorScheme = colorScheme
  }
  
  public func activeTheme(for colorScheme: HelloThemeScheme) -> HelloTheme {
    set(colorScheme: colorScheme)
    return activeTheme
  }
}
