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
  
  public var highestLevelSubscription: HelloSubscription? {
    subscriptions.values.max { $0.level < $1.level }
  }
  
  public var activeSubscriptionFromThisApp: HelloSubscription? {
    storeModel.validSubscriptions
      .compactMap { HelloSubscriptionOption.infer(from: $0.productID) }
      .map {
        if AppInfo.isTestBuild {
          HelloSubscription.test
        } else {
          HelloSubscription.new(for: $0.tier)
        }
      }
      .first
  }
  
  public var isActuallySubscribed: Bool {
    highestLevelSubscription?.isValidSubscription == true
  }
  
  public var isPromo: Bool {
    if case .promo = highestLevelSubscription?.type {
      true
    } else {
      false
    }
  }
  
  public var allowPremiumFeatures: Bool {
    highestLevelSubscription?.isValid == true
  }
  
  public var isSubscribedFromThisApp: Bool {
    subscriptions[AppInfo.rootBundleID]?.isValid == true
  }
  
  public var appSubscribedFrom: KnownApp? {
    guard highestLevelSubscription?.isValidSubscription == true,
          let bundleID = highestLevelSubscription?.appBundleID else {
      return nil
    }
    return .app(for: bundleID)
  }
  
  func set(developerIsSubscribed: Bool) {
    guard !isActuallySubscribed else { return }
    if developerIsSubscribed {
      subscriptionsModel.value[AppInfo.rootBundleID] = .developer
    } else {
      subscriptionsModel.value[AppInfo.rootBundleID] = nil
    }
  }
  
  func applyPromo(global: Bool) {
    subscriptionsModel.value[AppInfo.rootBundleID] = global ? .promoGlobal : .promoLocal
  }
  
  func removePromo() {
    if case .promo = subscriptionsModel.value[AppInfo.rootBundleID]?.type {
      subscriptionsModel.value[AppInfo.rootBundleID] = nil
    }
  }
  
  func refresh() {
    guard storeModel.isSetup else { return }
    if let subscription = activeSubscriptionFromThisApp {
      if subscriptions[AppInfo.bundleID] != subscription {
        subscriptionsModel.value[AppInfo.bundleID] = subscription
      }
    } else {
      if subscriptions[AppInfo.bundleID]?.isValid == true {
        subscriptionsModel.value[AppInfo.bundleID]?.isValid = false
      }
    }
  }
  
  func purchase(productID: String) async throws {
    try await storeModel.purchase(id: productID)
  }
  
  var isDeveloperSubscribed: Bool {
    subscriptions[AppInfo.developerHelloApp]?.isValid == true
  }
}
