import Foundation

public struct StaticHelloAppIcon: HelloAppIcon {
  public var id: String { "static" }
  
  public var name: String { "Static" }
  
  public var availability: FeatureAvailability { .paid }
}

public extension HelloAppIcon where Self == StaticHelloAppIcon {
  static var `static`: StaticHelloAppIcon { StaticHelloAppIcon() }
}
