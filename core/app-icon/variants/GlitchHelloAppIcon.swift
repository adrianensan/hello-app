import Foundation

public struct GlitchHelloAppIcon: HelloAppIcon {
  public var id: String { "glitch" }
  
  public var name: String { "Glitch" }
  
  public var availability: FeatureAvailability { .paid }
}

public extension HelloAppIcon where Self == GlitchHelloAppIcon {
  static var glitch: GlitchHelloAppIcon { GlitchHelloAppIcon() }
}
