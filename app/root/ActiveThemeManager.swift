import Foundation
import Combine

import HelloCore

public class ActiveThemeManager: ObservableObject {
  
  public static let main = ActiveThemeManager()
  
  @Published public private(set) var lightTHeme: HelloTheme = .light
  @Published public private(set) var darkTHeme: HelloTheme = .dark
  
  public func set(theme: some HelloThemeSet) {
    lightTHeme = theme.lightTheme
    darkTHeme = theme.darkTheme
  }
}
