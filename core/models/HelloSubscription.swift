import Foundation

public struct HelloSubscription: Codable, Equatable, Sendable {
  
  public enum Frequency: Codable, Sendable {
    case monthly
    case yearly
  }
  
  public var appBundleID: String
  public var tier: Int
  public var isValid: Bool
  public var isTest: Bool
  
  init(appBundleID: String,
       tier: Int,
       isValid: Bool,
       isTest: Bool) {
    self.appBundleID = appBundleID
    self.tier = tier
    self.isValid = isValid
    self.isTest = isTest
  }
  
  public static var developer: HelloSubscription {
    HelloSubscription(
      appBundleID: "com.adrianensan.hello",
      tier: 1,
      isValid: true,
      isTest: false)
  }
  
  public static var promo: HelloSubscription {
    HelloSubscription(
      appBundleID: "com.adrianensan.promo",
      tier: 1,
      isValid: true,
      isTest: false)
  }
  
  public static func new(for tier: Int) -> HelloSubscription {
    HelloSubscription(appBundleID: AppInfo.bundleID,
                      tier: tier,
                      isValid: true,
                      isTest: AppInfo.isTestBuild)
  }
}
