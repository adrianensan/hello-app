import Foundation

public protocol HelloBundleResource: Sendable {
  
  var name: String { get }
}


public extension HelloBundleResource {
  var url: URL? {
    Bundle.main.url(forResource: name, withExtension: nil)
  }
}
