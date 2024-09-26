import Foundation

public struct CRTHelloAppIcon: HelloAppIcon {
  public var id: String { "crt" }
  
  public var name: String { "CRT" }
  
  public var availability: FeatureAvailability { .paid }
}

public extension HelloAppIcon where Self == CRTHelloAppIcon {
  static var crt: CRTHelloAppIcon { CRTHelloAppIcon() }
}
