import Foundation

public struct DefaultStandardTintHelloAppIcon: HelloAppIcon {
  public var id: String { "default" }
  
  public var name: String { "Default" }
  
  public var availability: FeatureAvailability { .free }
  
  public var tint: HelloAppIconTint
}

public extension HelloAppIcon where Self == DefaultStandardTintHelloAppIcon {
  static func defaultStandard(tint: HelloAppIconTint) -> DefaultStandardTintHelloAppIcon {
    DefaultStandardTintHelloAppIcon(tint: tint)
  }
}

public struct StandardTintHelloAppIcon: HelloTintableAppIcon {
  public static func icon(for tint: HelloAppIconTint) -> StandardTintHelloAppIcon {
    StandardTintHelloAppIcon(tint: .black)
  }
  
  public var tint: HelloAppIconTint
  
  public init(tint: HelloAppIconTint) {
    self.tint = tint
  }
  
  public var id: String { "standard-\(tint.id)" }
  
  public var name: String { "Standard" }
  
  public var availability: FeatureAvailability { .paid }
}

public extension HelloAppIcon where Self == StandardTintHelloAppIcon {
  static func standard(tint: HelloAppIconTint) -> StandardTintHelloAppIcon {
    StandardTintHelloAppIcon(tint: tint)
  }
}

public extension HelloTintableAppIcon where Self == StandardTintHelloAppIcon {
  static func standard(tint: HelloAppIconTint) -> StandardTintHelloAppIcon {
    StandardTintHelloAppIcon(tint: tint)
  }
}
