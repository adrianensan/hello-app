import Foundation

public struct TikTokHelloAppIcon: HelloAppIcon {
  public var id: String { "tiktok" }
  
  public var name: String { "On The Clock" }
  
  public var availability: FeatureAvailability { .paid }
}

public extension HelloAppIcon where Self == TikTokHelloAppIcon {
  static var tiktok: TikTokHelloAppIcon { TikTokHelloAppIcon() }
}
