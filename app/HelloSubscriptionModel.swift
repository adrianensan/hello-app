import Foundation
import StoreKit

import HelloCore

package enum HelloSubscriptionOption: Identifiable, Codable, Sendable, CaseIterable {
  case tier1Monthly
  case tier1Yearly
  case tier2Monthly
  case tier2Yearly
  case tier3Monthly
  case tier3Yearly
  
  package enum Frequency {
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
  
  package var id: String {
    switch self {
    case .tier1Monthly: AppInfo.rootBundleID + ".subscription.tier1.monthly"
    case .tier1Yearly: AppInfo.rootBundleID + ".subscription.tier1.yearly"
    case .tier2Monthly: AppInfo.rootBundleID + ".subscription.tier2.monthly"
    case .tier2Yearly: AppInfo.rootBundleID + ".subscription.tier2.yearly"
    case .tier3Monthly: AppInfo.rootBundleID + ".subscription.tier3.monthly"
    case .tier3Yearly: AppInfo.rootBundleID + ".subscription.tier3.yearly"
    }
  }
  
  package var frequency: Frequency {
    switch self {
    case .tier1Monthly: .monthly
    case .tier1Yearly: .yearly
    case .tier2Monthly: .monthly
    case .tier2Yearly: .yearly
    case .tier3Monthly: .monthly
    case .tier3Yearly: .yearly
    }
  }
  
  package var tier: Int {
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

struct HelloSubscriptionCloudProperty: ICloudProperty {
  typealias Value = [String: HelloSubscription]
  
  var recordID: String { "hello-subscriptions" }
  
  var recordType: String { "HelloSubscriptionsMap" }
  
  var valueType: ICloudPropertyValueType { .data }
  
  var scope: ICloudPropertyScope { .hello }
}

extension ICloudProperty where Self == HelloSubscriptionCloudProperty {
  static var helloSubscriptions: HelloSubscriptionCloudProperty {
    HelloSubscriptionCloudProperty()
  }
}

@MainActor
@Observable
public class HelloSubscriptionModel {
  
  public static let main = HelloSubscriptionModel()
  
  private let storeModel: StoreModel = .main
  
  private var subscriptionsModel = Persistence.model(for: .subscriptions)
  
  package var isPurchasing: Bool { storeModel.isPurchasing }
  
  private init() {
    storeModel.setup(knownProductIDs: HelloSubscriptionOption.allCases.map { $0.id })
    refresh()
  }
  
  package var tier1MonthlyProduct: Product? { storeModel.availableProducts[HelloSubscriptionOption.tier1Monthly.id] }
  package var tier1YearlyProduct: Product? { storeModel.availableProducts[HelloSubscriptionOption.tier1Yearly.id] }
  package var tier2MonthlyProduct: Product? { storeModel.availableProducts[HelloSubscriptionOption.tier2Monthly.id] }
  package var tier2YearlyProduct: Product? { storeModel.availableProducts[HelloSubscriptionOption.tier2Yearly.id] }
  package var tier3MonthlyProduct: Product? { storeModel.availableProducts[HelloSubscriptionOption.tier3Monthly.id] }
  package var tier3YearlyProduct: Product? { storeModel.availableProducts[HelloSubscriptionOption.tier3Yearly.id] }
  
  package func product(for subscriptionOption: HelloSubscriptionOption) -> Product? {
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
  
  public var isDeveloperEnabled: Bool {
    subscriptionsModel.value[AppInfo.rootBundleID]?.type == .developer
  }
  
  public var allowPremiumFeatures: Bool {
    highestLevelSubscription?.isValid == true
  }
  
  public var allowSuperPremiumFeatures: Bool {
    highestLevelSubscription?.isValidSuperSubscription == true
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
  
  package func set(developerIsSubscribed: Bool) {
    if developerIsSubscribed {
      if subscriptionsModel.value[AppInfo.rootBundleID]?.isValid != true {
        updateSubscription(to: .developer)
      }
    } else if case .developer = subscriptionsModel.value[AppInfo.rootBundleID]?.type {
      updateSubscription(to: nil)
    }
  }
  
  package func applyPromo(global: Bool) {
    guard !isActuallySubscribed else { return }
    updateSubscription(to: global ? .promoGlobal : .promoLocal)
  }
  
  package func removePromo() {
    if case .promo = subscriptionsModel.value[AppInfo.rootBundleID]?.type {
      updateSubscription(to: nil)
    }
  }
  
  private func updateSubscription(to targetSubscription: HelloSubscription?) {
    guard subscriptionsModel.value[AppInfo.rootBundleID] != targetSubscription else { return }
    subscriptionsModel.value[AppInfo.rootBundleID] = targetSubscription
    sync(hasLocalChanged: true)
  }
  
  func refresh() {
    guard storeModel.isSetup else { return }
    var hasChanged = false
    if let subscription = activeSubscriptionFromThisApp {
      if subscriptions[AppInfo.bundleID] != subscription {
        subscriptionsModel.value[AppInfo.bundleID] = subscription
        hasChanged = true
      }
    } else {
      if let existingSubscription = subscriptions[AppInfo.bundleID], existingSubscription.isValid {
        switch existingSubscription.type {
        case .paid:
          if !AppInfo.isTestBuild {
            if existingSubscription.isValid {
              subscriptionsModel.value[AppInfo.bundleID]?.isValid = false
              hasChanged = true
            }
          } else {
            subscriptionsModel.value[AppInfo.bundleID] = nil
            hasChanged = true
          }
        case .test:
          if AppInfo.isTestBuild {
            if existingSubscription.isValid {
              subscriptionsModel.value[AppInfo.bundleID]?.isValid = false
              hasChanged = true
            }
          } else {
            subscriptionsModel.value[AppInfo.bundleID] = nil
            hasChanged = true
          }
        default: ()
        }
      }
    }
    var premiumIcons = ["gold"]
    var unlockedIcons = Persistence.mainActorValue(.unlockedAppIcons)
    if allowSuperPremiumFeatures {
      if !unlockedIcons.isSuperset(of: premiumIcons) {
        Persistence.mainActorSave(unlockedIcons.union(premiumIcons), for: .unlockedAppIcons)
      }
    } else if !unlockedIcons.intersection(premiumIcons).isEmpty {
      Persistence.mainActorSave(unlockedIcons.subtracting(premiumIcons), for: .unlockedAppIcons)
    }
    sync(hasLocalChanged: hasChanged)
  }
  
  public func restorePurchases() async throws {
    try await storeModel.refresh()
  }
  
  package func purchase(productID: String) async throws {
    try await storeModel.purchase(id: productID)
  }
  
  private func sync(hasLocalChanged: Bool) {
    Task {
      try await ICloudSyncManager.main.sync(
        property: .helloSubscriptions,
        persistenceProperty: .subscriptions,
        hasLocalUpdates: hasLocalChanged) { localValue, cloudValue in
          var mergedValue = cloudValue
          mergedValue[AppInfo.bundleID] = localValue[AppInfo.bundleID]
          return mergedValue
        }
    }
  }
}
