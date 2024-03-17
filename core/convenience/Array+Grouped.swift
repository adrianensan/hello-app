import Foundation

public extension Array {
  
  mutating func popFirst() -> Element? {
    guard !isEmpty else { return nil }
    return removeFirst()
  }
  
  func grouped<Key: Hashable>(by keyGetter: (Element) -> Key) -> [[Element]] {
    var keyOrder: [Key] = []
    var grouped: [Key: [Element]] = [:]
    for element in self {
      let key = keyGetter(element)
      if keyOrder.last != key {
        keyOrder.append(key)
      }
      let keyElements = grouped[key] ?? []
      grouped[key] = keyElements + [element]
    }
    return keyOrder.compactMap { grouped[$0] }
  }
}

public extension Array {
  init(repeating: [Element], count: Int) {
    self.init([[Element]](repeating: repeating, count: count).flatMap{$0})
  }
  
  func repeated(count: Int) -> [Element] {
    return [Element](repeating: self, count: count)
  }
}

public extension Collection where Element: Equatable {
  func remove(_ element: Element) {
    filter { $0 != element }
  }
}

public extension ArraySlice {
  func repeated(count: Int) -> [Element] {
    [Element](repeating: [Element](self), count: count)
  }
}

public extension Array where Element: Identifiable {
  var idsMappedToValues: [Element.ID: Element] {
    Dictionary(map { ($0.id, $0) }, uniquingKeysWith: { (first, _) in first })
  }
}
