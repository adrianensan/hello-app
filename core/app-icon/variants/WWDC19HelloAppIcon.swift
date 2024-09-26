import Foundation

public struct WWDC19HelloAppIcon: HelloAppIcon {
  public var id: String { "wwdc-19" }
  
  public var name: String { "Dub Dub 19" }
  
  public var availability: FeatureAvailability { .paid }
}

public extension HelloAppIcon where Self == WWDC19HelloAppIcon {
  static var wwdc19: WWDC19HelloAppIcon { WWDC19HelloAppIcon() }
}
