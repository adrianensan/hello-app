import Foundation

public protocol HelloAppConfig {
  associatedtype AppIconConfig: HelloAppIconConfig
  
  var id: String { get }
  var name: String { get }
  var hasPremiumFeatures: Bool { get }
}

public extension HelloAppConfig {
  var hasPremiumFeatures: Bool { false }
}
