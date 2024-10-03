import Foundation

public protocol HelloAppIconConfig: Codable, Hashable, Sendable {
  
  var defaultIcon: any HelloAppIcon { get }
  
  var platforms: [HelloAppPlatform] { get }
  
  var collections: [HelloAppIconCollection] { get }
  
  var betaIcons: [any HelloAppIcon] { get }
  var superPremiumIcons: [any HelloAppIcon] { get }
  
  var tintOptions: [HelloAppIconTint] { get }
  func tintableIcons(for tint: HelloAppIconTint) -> [any HelloTintableAppIcon]
}

public extension HelloAppIconConfig {
  
  var betaIcons: [any HelloAppIcon] { [.testflight, .placeholder] }
  var superPremiumIcons: [any HelloAppIcon] { [.gold] }
  
  var tintOptions: [HelloAppIconTint] { HelloAppIconTint.defaultOptions }
  
  var collections: [HelloAppIconCollection] { [] }
  func tintableIcons(for tint: HelloAppIconTint) -> [any HelloTintableAppIcon] { [] }
  
  var mainIcons: [any HelloAppIcon] { [defaultIcon] + betaIcons + superPremiumIcons }

  var tintedIcons: [any HelloAppIcon] {
    tintOptions.reduce([]) { icons, tint in icons + tintableIcons(for: tint) }
  }
  
  var all: [any HelloAppIcon] {
    [[defaultIcon],
     betaIcons,
     superPremiumIcons,
     collections.reduce([]) { $0 + $1.icons },
     tintedIcons,
    ].reduce([]) { $0 + $1 }
  }
  
  func icon(for id: String) -> (any HelloAppIcon)? {
    Dictionary(all.map { ($0.systemName, $0) }, uniquingKeysWith: { (first, _) in first })[id]
  }
}
