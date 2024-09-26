import Foundation

public struct GoldHelloAppIcon: HelloAppIcon {
  public var id: String { "gold" }
  
  public var name: String { "Gold" }
  
  public var availability: FeatureAvailability { .hidden }
}

public extension HelloAppIcon where Self == GoldHelloAppIcon {
  static var gold: GoldHelloAppIcon { GoldHelloAppIcon() }
}
