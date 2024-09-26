import Foundation

public struct EyesHelloAppIcon: HelloTintableAppIcon {
  public static func icon(for tint: HelloAppIconTint) -> StandardTintHelloAppIcon {
    .icon(for: .black)
  }
  
  public var tint: HelloAppIconTint
  
  public init(tint: HelloAppIconTint) {
    self.tint = tint
  }
  
  public var id: String { "eyes-\(tint.id)" }
  
  public var name: String { "Eyes" }
  
  public var availability: FeatureAvailability { .paid }
}

public extension HelloAppIcon where Self == EyesHelloAppIcon {
  static func eyes(tint: HelloAppIconTint) -> EyesHelloAppIcon {
    EyesHelloAppIcon(tint: tint)
  }
}

public extension HelloTintableAppIcon where Self == EyesHelloAppIcon {
  static func eyes(tint: HelloAppIconTint) -> EyesHelloAppIcon {
    EyesHelloAppIcon(tint: tint)
  }
}
