import SwiftUI

import HelloCore

@MainActor
@Observable
public class AppIconModel<AppIcon: BaseAppIcon> {
  
  public private(set) var currentIcon: AppIcon = .defaultIcon
  
  @ObservationIgnored @Persistent(.activeAppIcon) var activeAppIcon
  @ObservationIgnored @Persistent(.unlockedAppIcons) var unlockedAppIcons
  
  public var collections: [AppIconCollection<AppIcon>] = []
  
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
    collections = AppIcon.collections
      .map {
        var collection = $0
        collection.icons = $0.icons.filter { $0.availability.isAlwaysVisible || unlockedAppIcons.contains($0.id) }
        return collection
      }.filter { !$0.icons.isEmpty }
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
