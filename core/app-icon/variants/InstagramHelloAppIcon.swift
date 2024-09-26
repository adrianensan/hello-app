import Foundation

public struct InstagramHelloAppIcon: HelloAppIcon {
  public var id: String { "instagram" }
  
  public var name: String { "Influencer" }
  
  public var availability: FeatureAvailability { .paid }
}

public extension HelloAppIcon where Self == InstagramHelloAppIcon {
  static var instagram: InstagramHelloAppIcon { InstagramHelloAppIcon() }
}
