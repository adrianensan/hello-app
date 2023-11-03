import Foundation

public extension Sequence {
  func map<T>(_ transform: @Sendable (Element) async throws -> T) async rethrows -> [T] {
    var values = [T]()
    
    for element in self {
      try await values.append(transform(element))
    }
    
    return values
  }
}
