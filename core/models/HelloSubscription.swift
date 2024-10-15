import Foundation

public struct HelloSubscription: Codable, Equatable, Sendable {
  
  public enum HelloSubscriptionType: Codable, Equatable, Sendable {
    case test
    case paid(tier: Int)
    case developer
    case promo(global: Bool)
    
    public var id: String {
      switch self {
      case .test: "test"
      case .paid(let tier): "tier-\(tier)"
      case .developer: "dev"
      case .promo(let global): "promo-\(global ? "global" : "local")"
      }
    }
    
    public var description: String {
      switch self {
      case .test: "Test"
      case .paid(let tier): "Tier \(tier)"
      case .developer: "Dev"
      case .promo(let global): "Promo \(global ? "Global" : "Local")"
      }
    }
  }
  
  public enum Frequency: Codable, Sendable {
    case monthly
    case yearly
  }
  
  public var appBundleID: String
  public var type: HelloSubscriptionType
  public var isValid: Bool
  
  init(appBundleID: String,
       type: HelloSubscriptionType,
       isValid: Bool) {
    self.appBundleID = appBundleID
    self.type = type
    self.isValid = isValid
  }
  
  public var isTest: Bool {
    type == .test
  }
  
  public var isActiveApp: Bool {
    AppInfo.rootBundleID == appBundleID
  }
  
  public var isGlobal: Bool {
    switch type {
    case .test: false
    case .paid(let tier): true
    case .developer: true
    case .promo(let global): global
    }
  }
  
  public var isValidSubscription: Bool {
    guard isValid else { return false }
    return switch type {
    case .test: true
    case .paid(let tier): true
    case .developer: false
    case .promo: false
    }
  }
  
  public var isValidSuperSubscription: Bool {
    guard isValid else { return false }
    return switch type {
    case .test: true
    case .paid(let tier): tier > 1
    case .developer: true
    case .promo: false
    }
  }
  
  public var level: Int {
    var int = 0
    if isValid {
      int += 100
    }
    switch type {
    case .test:
      int += 10
      if isActiveApp {
        int += 1
      }
    case .paid(let tier):
      int += 50 + 2 * tier
      if isActiveApp {
        int += 1
      }
    case .developer:
      int += 40
    case .promo(let global):
      int += global ? 20 : 2
    }
    return int
  }
  
  public static var developer: HelloSubscription {
    HelloSubscription(
      appBundleID: AppInfo.bundleID,
      type: .developer,
      isValid: true)
  }
  
  public static var promoGlobal: HelloSubscription {
    HelloSubscription(
      appBundleID: AppInfo.bundleID,
      type: .promo(global: true),
      isValid: true)
  }
  
  public static var promoLocal: HelloSubscription {
    HelloSubscription(
      appBundleID: AppInfo.bundleID,
      type: .promo(global: true),
      isValid: true)
  }
  
  public static var test: HelloSubscription {
    HelloSubscription(
      appBundleID: AppInfo.bundleID,
      type: .test,
      isValid: true)
  }
  
  public static func new(for tier: Int) -> HelloSubscription {
    HelloSubscription(appBundleID: AppInfo.bundleID,
                      type: .paid(tier: tier),
                      isValid: true)
  }
}
