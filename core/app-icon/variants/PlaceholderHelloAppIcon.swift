import Foundation

public struct PlaceholderHelloAppIcon: HelloAppIcon {
  public var id: String { "placeholder" }
  
  public var name: String { "Placeholder" }
  
  public var availability: FeatureAvailability { .hidden }
}

public extension HelloAppIcon where Self == PlaceholderHelloAppIcon {
  static var placeholder: PlaceholderHelloAppIcon { PlaceholderHelloAppIcon() }
}
