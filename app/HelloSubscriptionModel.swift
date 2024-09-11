import Foundation
import StoreKit

import HelloCore

enum HelloSubscriptionOption: Identifiable, Codable, Sendable, CaseIterable {
  case tier1Monthly
  case tier1Yearly
  case tier2Monthly
  case tier2Yearly
  case tier3Monthly
  case tier3Yearly
  
  enum Frequency {
    case monthly
    case yearly
    
    public var name: String {
      switch self {
      case .monthly: "Monthly"
      case .yearly: "Yearly"
      }
    }
    
    public var unit: String {
      switch self {
      case .monthly: "month"
      case .yearly: "year"
      }
    }
    
    public var shortUnit: String {
      switch self {
      case .monthly: "m"
      case .yearly: "yr"
      }
    }
  }
  
  public static func infer(from id: String) -> HelloSubscriptionOption? {
    for option in HelloSubscriptionOption.allCases {
      if id == option.id {
        return option
      }
    }
    return nil
  }
  
  public var id: String {
    switch self {
    case .tier1Monthly: AppInfo.rootBundleID + ".subscription.tier1.monthly"
    case .tier1Yearly: AppInfo.rootBundleID + ".subscription.tier1.yearly"
    case .tier2Monthly: AppInfo.rootBundleID + ".subscription.tier2.monthly"
    case .tier2Yearly: AppInfo.rootBundleID + ".subscription.tier2.yearly"
    case .tier3Monthly: AppInfo.rootBundleID + ".subscription.tier3.monthly"
    case .tier3Yearly: AppInfo.rootBundleID + ".subscription.tier3.yearly"
    }
  }
  
  public var frequency: Frequency {
    switch self {
    case .tier1Monthly: .monthly
    case .tier1Yearly: .yearly
    case .tier2Monthly: .monthly
    case .tier2Yearly: .yearly
    case .tier3Monthly: .monthly
    case .tier3Yearly: .yearly
    }
  }
  
  public var tier: Int {
    switch self {
    case .tier1Monthly: 1
    case .tier1Yearly: 1
    case .tier2Monthly: 2
    case .tier2Yearly: 2
    case .tier3Monthly: 3
    case .tier3Yearly: 3
    }
  }
}

@MainActor
@Observable
public class HelloSubscriptionModel {
  
  public static let main = HelloSubscriptionModel()
  
  private let storeModel: StoreModel = .main
  
  private var subscriptionsModel = Persistence.model(for: .subscriptions)
  
  var isPurchasing: Bool { storeModel.isPurchasing }
  
  init() {
    storeModel.setup(knownProductIDs: HelloSubscriptionOption.allCases.map { $0.id })
    refresh()
  }
  
  public var tier1MonthlyProduct: Product? { storeModel.availableProducts[HelloSubscriptionOption.tier1Monthly.id] }
  var tier1YearlyProduct: Product? { storeModel.availableProducts[HelloSubscriptionOption.tier1Yearly.id] }
  var tier2MonthlyProduct: Product? { storeModel.availableProducts[HelloSubscriptionOption.tier2Monthly.id] }
  var tier2YearlyProduct: Product? { storeModel.availableProducts[HelloSubscriptionOption.tier2Yearly.id] }
  var tier3MonthlyProduct: Product? { storeModel.availableProducts[HelloSubscriptionOption.tier3Monthly.id] }
  var tier3YearlyProduct: Product? { storeModel.availableProducts[HelloSubscriptionOption.tier3Yearly.id] }
  
  func product(for subscriptionOption: HelloSubscriptionOption) -> Product? {
    storeModel.availableProducts[subscriptionOption.id]
  }

  private var subscriptions: [String: HelloSubscription] {
    subscriptionsModel.value
  }
  
  public var activeSubscription: HelloSubscription? {
    subscriptions.values.first {
      $0.isValid && (!$0.isTest || AppInfo.isTestBuild) && $0.appBundleID != HelloSubscription.promo.appBundleID
    }
  }
  
  public var activeSubscriptionFromThisApp: HelloSubscription? {
    storeModel.validSubscriptions
      .compactMap { HelloSubscriptionOption.infer(from: $0.productID) }
      .map { HelloSubscription.new(for: $0.tier) }
      .first
  }
  
  public var isSubscribed: Bool {
    activeSubscription != nil
  }
  
  public var isPromo: Bool {
    subscriptions[HelloSubscription.promo.appBundleID]?.isValid == true
  }
  
  public var allowPremiumFeatures: Bool {
    activeSubscription != nil || isPromo
  }
  
  public var isSubscribedFromThisApp: Bool {
    subscriptions[AppInfo.rootBundleID]?.isValid == true
  }
  
  public var appSubscribedFrom: KnownApp? {
    guard let bundleID = activeSubscription?.appBundleID else { return nil }
    return .app(for: bundleID)
  }
  
  private func setSubscribed(tier: Int) {
    if subscriptions[AppInfo.bundleID] != .new(for: tier) {
      subscriptionsModel.value[AppInfo.bundleID] = .new(for: tier)
    }
  }
  
  private func setUnsubscribed() {
    if subscriptions[AppInfo.bundleID]?.isValid == true {
      subscriptionsModel.value[AppInfo.bundleID]?.isValid = false
    }
  }
  
  func set(developerIsSubscribed: Bool) {
    if developerIsSubscribed {
      subscriptionsModel.value[AppInfo.developerHelloApp] = .developer
    } else {
      subscriptionsModel.value[AppInfo.developerHelloApp] = nil
    }
  }
  
  func refresh() {
    guard storeModel.isSetup else { return }
    if let subscription = activeSubscriptionFromThisApp {
      setSubscribed(tier: subscription.tier)
    } else {
      setUnsubscribed()
    }
  }
  
  func purchase(productID: String) async throws {
    try await storeModel.purchase(id: productID)
  }
  
  var isDeveloperSubscribed: Bool {
    subscriptions[AppInfo.developerHelloApp]?.isValid == true
  }
}
