import Foundation

public protocol HelloAppConfig {
  var id: String { get }
  var name: String { get }
  var hasPremiumFeatures: Bool { get }
  var appIconConfig: any HelloAppIconConfig { get }
}

public extension HelloAppConfig {
  var hasPremiumFeatures: Bool { false }
}
