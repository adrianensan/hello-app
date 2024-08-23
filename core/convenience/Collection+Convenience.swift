import Foundation

public extension Collection {
  // Async map
  func map<T>(_ transform: @Sendable (Element) async throws -> T) async rethrows -> [T] {
    var values = [T]()
    
    for element in self {
      try await values.append(transform(element))
    }
    
    return values
  }
  
  // Efficient first element of compactMap
  func firstCompactMap<Result>(_ transform: @escaping (Element) throws -> Result?) rethrows -> Result? {
    self.lazy.compactMap { try? transform($0) }.first
  }
}

public extension Collection where Element: Identifiable {
  func removingDuplicates() -> [Element] {
    var addedDict = [Element.ID: Bool]()
    
    return filter {
      addedDict.updateValue(true, forKey: $0.id) == nil
    }
  }
}

//public extension Collection where Element: Hashable {
//  func removingDuplicates() -> [Element] {
//    var addedDict = [Element: Bool]()
//    
//    return filter {
//      addedDict.updateValue(true, forKey: $0) == nil
//    }
//  }
//}

public extension Collection where Element: Numeric {
  func sum() -> Element {
    reduce(0) { $0 + $1 }
  }
}

public extension Array where Element: Identifiable {
  mutating func removeDuplicates() {
    self = self.removingDuplicates()
  }
}
