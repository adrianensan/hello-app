import Foundation

public protocol HelloBundleResource: Sendable {
  
  var name: String { get }
}

public struct AnyBundleResource: HelloBundleResource {
  
  public var name: String
  
  public init(fileName: String) {
    name = fileName
  }
}

extension HelloBundleResource where Self == AnyBundleResource {
  public static func any(fileName: String) -> AnyBundleResource {
    AnyBundleResource(fileName: fileName)
  }
}

public extension Bundle {
  func url(for resource: some HelloBundleResource) -> URL? {
    url(forResource: resource.name, withExtension: nil)
  }
}
