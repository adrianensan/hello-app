import Foundation

public struct SubscriptionsPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: [String: HelloSubscription] { [:] }
  
  public func defaultValue(for mode: PersistenceMode) -> [String : HelloSubscription] {
    switch mode {
    case .normal: defaultValue
    case .demo: [HelloSubscription.developer.appBundleID: .developer]
    case .freshInstall: defaultValue
    }
  }
  
  public var location: PersistenceType { .file(location: .helloShared, path: "subscriptions.json") }
}

public extension PersistenceProperty where Self == SubscriptionsPersistenceProperty {
  static var subscriptions: SubscriptionsPersistenceProperty {
    SubscriptionsPersistenceProperty()
  }
}
