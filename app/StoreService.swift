import Foundation

import HelloCore

public protocol StoreProduct: CaseIterable, Codable, Sendable, Identifiable {
  var id: String { get }
  var name: String { get }
}

public struct AvailableStoreProduct: Codable, Sendable, Identifiable {
  public var id: String
  public var price: String
}

public struct ProductTransaction<ProductType: StoreProduct>: Codable, Sendable {
  public var id: String
  public var name: String
  public var price: Decimal
  public var product: ProductType
}

public enum StoreServiceError: Error {
  case userCancelled
  case unknownError
  case unverified
}

import StoreKit

public enum HelloSubscriptionState: Sendable {
  case active
  case gracePeriod
  case billingRetryPeriod
  case expired
  case revoked
  case unknown
  
  public var isValid: Bool {
    switch self {
    case .active: true
    case .gracePeriod: true
    case .billingRetryPeriod: true
    case .expired: false
    case .revoked: false
    case .unknown: false
    }
  }
}

extension HelloSubscriptionState {
  static func infer(from storekitSubscriptionState: Product.SubscriptionInfo.RenewalState) -> HelloSubscriptionState {
    switch storekitSubscriptionState {
    case .subscribed: .active
    case .inGracePeriod: .gracePeriod
    case .inBillingRetryPeriod: .billingRetryPeriod
    case .expired: .expired
    case .revoked: .revoked
    default: .unknown
    }
  }
}

public struct HelloNativeSubscriptionInfo: Sendable {
  public var productID: String
  public var state: HelloSubscriptionState
}

@MainActor
@Observable
public class StoreModel {
  
  public static let main = StoreModel()
  
  public private(set) var availableProducts: [String: Product] = [:]
  public private(set) var isPurchasing: Bool = false
  public private(set) var validSubscriptions: [HelloNativeSubscriptionInfo] = []
  public private(set) var invalidSubscriptions: [HelloNativeSubscriptionInfo] = []
  
  public private(set) var subscriptions: [String] = []
  private var knownProductIDs: [String] = []
  public var isSetup: Bool = false
  
  private init() {
  }
  
  private func refreshProducts() async throws {
    guard availableProducts.count != knownProductIDs.count else {
      Log.verbose(context: "StoreKit", "Skipped loading products, all known products loaded")
      return
    }
    availableProducts = try await Product.products(for: knownProductIDs).idsMappedToValues
    let availableProductsCount = availableProducts.count
    let knownProductsCount = knownProductIDs.count
    if availableProductsCount == knownProductsCount {
      Log.info(context: "StoreKit", "Loaded all \(knownProductsCount) known products")
    } else {
      Log.error(context: "StoreKit", "Loaded \(availableProductsCount) of \(knownProductsCount) known products")
    }
  }
  
  public func setup(knownProductIDs: [String]) {
    self.knownProductIDs = knownProductIDs
    Task {
      try await refresh()
    }
  }
  
  public func refresh() async throws {
    do {
      try await refreshProducts()
      if !isSetup {
        isSetup = true
        listenForUpdates()
      }
      await refreshEntitlements()
    } catch {
      Log.error(context: "StoreKit", "Failed to refresh products: \(error.localizedDescription)")
    }
    
    //    Transaction.currentEntitlements
  }
  
  private func refreshEntitlements() async {
    var activeSubscriptions: [HelloNativeSubscriptionInfo] = []
    for await entitlement in Transaction.currentEntitlements {
      guard case .verified(let transaction) = entitlement else {
        Log.warning(context: "StoreKit", "Found unverified entitlement")
        continue
      }
      
      guard let subscriptionInfo = await transaction.subscriptionStatus else {
        Log.warning(context: "StoreKit", "Found transaction without subscription information")
        continue
      }
      
      activeSubscriptions.append(HelloNativeSubscriptionInfo(productID: transaction.productID,
                                                             state: .infer(from: subscriptionInfo.state)))
//        if transaction.expirationDate ?? .now > .now && transaction.revocationDate == nil && transaction.subscriptionStatus?.state == .{
//          activeProductIDs.append(transaction.productID)
//        }
    }
    validSubscriptions = activeSubscriptions.filter { $0.state.isValid }
    invalidSubscriptions = activeSubscriptions.filter { !$0.state.isValid }
    
    let validSubscriptionCount = validSubscriptions.count
    let invalidSubscriptionsCount = invalidSubscriptions.count
    Log.info(context: "StoreKit", "Refreshed entitlements: \(validSubscriptionCount) valid, \(invalidSubscriptionsCount) invalid")

    HelloSubscriptionModel.main.refresh()
  }
  
  private func listenForUpdates() {
    Task {
      for await result in Transaction.updates {
        Log.info(context: "StoreKit", "Transaction update")
        await result.unsafePayloadValue.finish()
        Task { await refreshEntitlements() }
      }
      Log.wtf(context: "StoreKit", "Update loop ended")
    }
    //    try await refreshProducts(knownProductIDs: knownProductIDs)
  }
  
  public func purchase(id productID: String) async throws {
    guard !isPurchasing, let product = availableProducts[productID] else { return }
    isPurchasing = true
    defer { isPurchasing = false }
    let purchaseResult = try await product.purchase()
    switch purchaseResult {
    case .success(let verification):
      switch verification {
      case .verified(let transaction):
        await transaction.finish()
        await refreshEntitlements()
      case .unverified(let transaction, _):
        await transaction.finish()
        throw StoreServiceError.unverified
      }
    case .userCancelled: throw StoreServiceError.userCancelled
    case .pending: return
    @unknown default: throw StoreServiceError.unknownError
    }
  }
}
