import Foundation

public extension Set {
  func grouped<ID: Hashable>(by identifier: (Element) -> ID) -> [ID: Set<Element>] {
    var map: [ID: Set<Element>] = [:]
    for element in self {
      let identifier = identifier(element)
      map[identifier] = (map[identifier] ?? []).union([element])
    }
    return map
  }
}
