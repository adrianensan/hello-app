import Foundation

public struct TestflightHelloAppIcon: HelloAppIcon {
  public var id: String { "beta-tester" }
  
  public var name: String { "Beta Tester" }
  
  public var availability: FeatureAvailability { .hidden }
}

public extension HelloAppIcon where Self == TestflightHelloAppIcon {
  static var testflight: TestflightHelloAppIcon { TestflightHelloAppIcon() }
}
