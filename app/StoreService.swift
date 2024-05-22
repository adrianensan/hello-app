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

#if os(iOS)
import StoreKit

public actor StoreService {
  
  public static let main: StoreService = StoreService()
  
  public var knownAvailableProducts: [Product] = []
  public var tips: [UInt64: Decimal] = [:]
  
  public private(set) var isPurchasing: Bool = false
  
  init() {
    Task { try await setup() }
  }
  
  public func refreshProducts(knownProductIDs: [String]) async throws -> [AvailableStoreProduct] {
    let products = try await Product.products(for: knownProductIDs)
    knownAvailableProducts = products
    return products.map { AvailableStoreProduct(id: $0.id, price: $0.displayPrice) }
  }
  
  private func updateTotal() async {
    for await result in Transaction.all {
      switch result {
      case .unverified(_, _): break
      case .verified(let transaction):
        guard let product = knownAvailableProducts.first(where: { $0.id == transaction.productID }) else { return }
        await transaction.finish()
      }
    }
  }
  
  private func setup() async throws {
    Task {
      for await result in Transaction.updates {
        switch result {
        case .verified(let transaction):
          guard let product = knownAvailableProducts.first(where:{ $0.id == transaction.productID }) else { break }
          await transaction.finish()
        case .unverified: break
        }
      }
    }
//    try await refreshProducts(knownProductIDs: knownProductIDs)
  }
  
  public func purchase(id productID: String) async throws {
    guard !isPurchasing, let product = knownAvailableProducts.first(where:{ $0.id == productID }) else { return }
    isPurchasing = true
    defer { isPurchasing = false }
    let purchaseResult = try await product.purchase()
    switch purchaseResult {
    case .success(let verification):
      switch verification {
      case .verified(let transaction):
        await transaction.finish()
      case .unverified(_, _): throw StoreServiceError.unverified
      }
    case .userCancelled: throw StoreServiceError.userCancelled
    case .pending: throw StoreServiceError.unknownError
    @unknown default: throw StoreServiceError.unknownError
    }
  }
}
#else
public class StoreService {
  
  public static var main: StoreService = StoreService() +& { $0.setup() }
  
  public var tipProducts: [String] = []
  public var tips: [UInt64: String] = [:]
  
  public func refreshProducts() {}
  
  private func updateTotal() {}
  
  private func setup() {}
  
  func purchase(id productID: String) {}
}
#endif
