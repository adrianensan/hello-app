import Foundation

public protocol HelloAppConfig {
  associatedtype AppIconConfig: HelloAppIconConfig
  
  var id: String { get }
  var name: String { get }
}
