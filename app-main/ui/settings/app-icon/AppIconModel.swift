import SwiftUI

import HelloCore
import HelloApp

public struct AppIconSection: Identifiable, Sendable {
  
  public var id: String
  public var name: String?
  public var icons: [AppIconOption]
  
  public init(id: String,
              name: String?,
              icons: [AppIconOption]) {
    self.id = id
    self.name = name
    self.icons = icons
  }
}

public struct AppIconOption: Identifiable, Sendable {
  
  public var icon: any HelloAppIcon
  public var isAvailable: Bool
  
  public var id: String { icon.id }
  
  public var name: String { icon.name }
}

extension HelloImageSource {
  static func appIconThumbnail(for icon: any HelloAppIcon) -> HelloImageSource {
    .resource(fileName: "hello-resources/app-icon-thumbnails/\(icon.systemName).heic")
  }
}

@MainActor
@Observable
public class AppIconModel {
  
  private let appIconConfig: any HelloAppIconConfig
  public private(set) var currentIcon: any HelloAppIcon
  
  private let subscriptionModel: HelloSubscriptionModel = .main
  
  @ObservationIgnored @Persistent(.activeAppIcon) var activeAppIcon
  @ObservationIgnored @Persistent(.unlockedAppIcons) var unlockedAppIcons
  
  public private(set) var mainIcons: [AppIconOption] = []
  public private(set) var tintedIcons: [AppIconOption] = []
  public private(set) var sections: [AppIconSection] = []
  private var imageModels: [HelloImageModel] = []
  
  public private(set) var selectedTint: HelloAppIconTint
  
  public init(appIconConfig: some HelloAppIconConfig) {
    self.appIconConfig = appIconConfig
    currentIcon = appIconConfig.defaultIcon
    selectedTint = appIconConfig.tintOptions.first ?? .blue
  }
  
  public var tintOptions: [HelloAppIconTint] { appIconConfig.tintOptions }
  
  private func showShow(icon: any HelloAppIcon) -> Bool {
    icon.availability.isAlwaysVisible || unlockedAppIcons.contains(icon.id)
  }
  
  public func setup() {
    imageModels = appIconConfig.all.map { HelloImageModel.model(for: .appIconThumbnail(for: $0)) }
    Task { imageModels.forEach { $0.loadAsync() } }
    refresh()
  }
  
  public func refresh() {
#if os(iOS)
    let currentIcon = UIApplication.shared.alternateIconName.flatMap { appIconConfig.icon(for: $0) } ?? appIconConfig.defaultIcon
    if self.currentIcon.id != currentIcon.id {
      self.currentIcon = currentIcon
    }
    if activeAppIcon != UIApplication.shared.alternateIconName {
      activeAppIcon = UIApplication.shared.alternateIconName
    }
#endif
    let allowPremiumIcons = subscriptionModel.allowPremiumFeatures
    mainIcons = appIconConfig.mainIcons.filter { showShow(icon: $0) }.map { AppIconOption(icon: $0, isAvailable: $0.availability.isAlwaysAvailable || allowPremiumIcons) }
    tintedIcons = appIconConfig.tintableIcons(for: selectedTint).map { AppIconOption(icon: $0, isAvailable: $0.availability.isAlwaysAvailable || allowPremiumIcons) }
    sections = appIconConfig.collections
      .map {
        var collection = $0
        collection.icons = $0.icons.filter { showShow(icon: $0) }
        return collection
      }.filter { !$0.icons.isEmpty }
      .map {
        AppIconSection(id: $0.id, name: $0.name, icons: $0.icons.map { AppIconOption(icon: $0, isAvailable: $0.availability.isAlwaysAvailable || allowPremiumIcons) })
      }
  }
  
  func updateTint(to newTint: HelloAppIconTint) {
    guard selectedTint != newTint else { return }
    selectedTint = newTint
    refresh()
  }
  
  func set(icon: any HelloAppIcon) {
    guard currentIcon.id != icon.id else { return }
    currentIcon = icon
#if os(iOS)
    UIApplication.shared.setAlternateIconName(appIconConfig.defaultIcon.id == icon.id ? nil : icon.systemName) { error in
      guard error == nil else {
        self.refresh()
        return
      }
      self.refresh()
    }
#endif
  }
}
