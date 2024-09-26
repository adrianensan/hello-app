import Foundation

public extension AppIconImageVariant {
  static let iOSClassic: [AppIconImageVariant] = [
    .init(platform: .ios, size: 1024)
  ]
  
  static let iOS: [AppIconImageVariant] = [
    .iOSMain,
    .iOSDarkAppearance,
    .iOSTintedAppearance,
  ]
  
  static var iOSMain: AppIconImageVariant {
    .init(platform: .ios, size: 1024)
  }
  
  static var visionOS: AppIconImageVariant {
    .init(idiom: .vision, scale: 2, size: 512)
  }
  
  static var iOSDarkAppearance: AppIconImageVariant {
    .init(platform: .ios, size: 1024, appearance: .dark)
  }
  
  static var iOSTintedAppearance: AppIconImageVariant {
    .init(platform: .ios, size: 1024, appearance: .tinted)
  }
  
  static var iOSThumbnail: AppIconImageVariant {
    .init(platform: .ios, scale: 3, size: 60)
  }
  
  static var watchOS: AppIconImageVariant { .init(platform: .watchos, idiom: .universal, size: 1024) }
  
  static let iOSAlternate: [AppIconImageVariant] = [
    .init(platform: .ios, scale: 2, size: 60),
    .init(platform: .ios, scale: 3, size: 60),
    .init(platform: .ios, scale: 2, size: 76),
    .init(platform: .ios, scale: 2, size: 83.5),
  ]
  
  static let iOSAlternateDarkAppearance: [AppIconImageVariant] = [
    .init(platform: .ios, scale: 2, size: 60, appearance: .dark),
    .init(platform: .ios, scale: 3, size: 60, appearance: .dark),
    .init(platform: .ios, scale: 2, size: 76, appearance: .dark),
    .init(platform: .ios, scale: 2, size: 83.5, appearance: .dark)
  ]
  
  static let iOSAlternateTintedAppearance: [AppIconImageVariant] = [
    .init(platform: .ios, scale: 2, size: 60, appearance: .tinted),
    .init(platform: .ios, scale: 3, size: 60, appearance: .tinted),
    .init(platform: .ios, scale: 2, size: 76, appearance: .tinted),
    .init(platform: .ios, scale: 2, size: 83.5, appearance: .tinted)
  ]
  
  static var iOSAlternateAppearances: [AppIconImageVariant] {
    AppIconImageVariant.iOSAlternate +
    AppIconImageVariant.iOSAlternateDarkAppearance +
    AppIconImageVariant.iOSAlternateTintedAppearance
  }
  
  static let iMessageVariants: [AppIconImageVariant] = [
    .init(idiom: .iphone, scale: 2, size: 29),
    .init(idiom: .iphone, scale: 3, size: 29),
    .init(idiom: .iphone, scale: 2, size: CGSize(width: 60, height: 45)),
    .init(idiom: .iphone, scale: 3, size: CGSize(width: 60, height: 45)),
    .init(idiom: .ipad, scale: 2, size: 29),
    .init(idiom: .ipad, scale: 2, size: CGSize(width: 67, height: 50)),
    .init(idiom: .ipad, scale: 2, size: CGSize(width: 74, height: 55)),
    .init(idiom: .iosMarketing, scale: 1, size: 1024),
    .init(platform: .ios, idiom: .universal, scale: 2, size: CGSize(width: 27, height: 20)),
    .init(platform: .ios, idiom: .universal, scale: 3, size: CGSize(width: 27, height: 20)),
    .init(platform: .ios, idiom: .universal, scale: 2, size: CGSize(width: 32, height: 24)),
    .init(platform: .ios, idiom: .universal, scale: 3, size: CGSize(width: 32, height: 24)),
    .init(platform: .ios, idiom: .iosMarketing, scale: 1, size: CGSize(width: 1024, height: 768)),
  ]
  
  static let macVariants: [AppIconImageVariant] = [
    .init(idiom: .mac, scale: 1, size: 16),
    .init(idiom: .mac, scale: 2, size: 16),
    .init(idiom: .mac, scale: 1, size: 32),
    .init(idiom: .mac, scale: 2, size: 32),
    .init(idiom: .mac, scale: 1, size: 128),
    .init(idiom: .mac, scale: 1, size: 256),
    .init(idiom: .mac, scale: 2, size: 256),
    .init(idiom: .mac, scale: 1, size: 512),
    .init(idiom: .mac, scale: 2, size: 512),
  ]
}
