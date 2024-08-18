import SwiftUI

import HelloCore

@MainActor
@Observable
public class AppIconModel<AppIcon: BaseAppIcon> {
  
  public private(set) var currentIcon: AppIcon = .defaultIcon
  
  @ObservationIgnored @Persistent(.activeAppIcon) var activeAppIcon
  
  public init() {
    refresh()
  }
  
  private func refresh() {
    #if os(iOS)
    let currentIcon = AppIcon.infer(from: UIApplication.shared.alternateIconName)
    if self.currentIcon != currentIcon {
      self.currentIcon = currentIcon
    }
    if activeAppIcon != UIApplication.shared.alternateIconName {
      activeAppIcon = UIApplication.shared.alternateIconName
    }
    #endif
  }
  
  func set(icon: AppIcon) {
    guard currentIcon != icon else { return }
    currentIcon = icon
    #if os(iOS)
    UIApplication.shared.setAlternateIconName(icon.systemName) { error in
      guard error == nil else {
        self.refresh()
        return
      }
      self.refresh()
    }
    #endif
  }
}
