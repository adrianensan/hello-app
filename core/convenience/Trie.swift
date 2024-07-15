import Foundation

public struct Trie<T: Codable & Hashable & Sendable>: Sendable {
  
//  public static func constructFrom<T: Codable & Hashable>(valuesMap: [String: T]) -> Trie<T> {
//    let root = Trie<T>()
//    
//    for (key, value) in valuesMap {
//      var currentNode: TrieNode<T> = root
//      for character in key.utf8 {
//        if let node = currentNode.map[character] {
//          currentNode = node
//          continue
//        } else {
//          let newNode = TrieNode<T>()
//          currentNode.map[character] = newNode
//          currentNode = newNode
//        }
//      }
//      currentNode.value.insert(value)
//    }
//    
//    return root
//  }
  
  public private(set) var value: Set<T> = []
  public private(set)  var map: [UInt8: Trie] = [:]
  
  public init(value: T? = nil) {
    if let value {
      self.value = [value]
    } else {
      self.value = []
    }
    self.map = [:]
  }
  
  enum TrieCodingKeys: CodingKey {
    case map
    case value
  }
  
  public func searchAllTrie() -> Set<T> {
    var results: Set<T> = Set()
    results.formUnion(value)
    
    for node in map.values {
      results.formUnion(node.searchAllTrie())
    }
    
    return results
  }
  
  public init(valueAndKeys: [(T, [String])]) {
    for (value, keys) in valueAndKeys {
      for key in keys {
        var currentNode: Trie<T> = self
        for character in key.utf8 {
          if let node = currentNode.map[character] {
            currentNode = node
            continue
          } else {
            let newNode = Trie<T>()
            currentNode.map[character] = newNode
            currentNode = newNode
          }
        }
        currentNode.value.insert(value)
      }
    }
  }
  
  public init(valuesMap: [String: T]) {
    for (key, value) in valuesMap {
      var currentNode: Trie<T> = self
      for character in key.utf8 {
        if let node = currentNode.map[character] {
          currentNode = node
          continue
        } else {
          let newNode = Trie<T>()
          currentNode.map[character] = newNode
          currentNode = newNode
        }
      }
      currentNode.value.insert(value)
    }
  }
  
//  public func add(value: T, for key: String, addAtEveryNode: Bool = false) {
//    add(value: value, for: [key], addAtEveryNode: addAtEveryNode)
//  }
  
//  public func add(value: T, for keys: [String], addAtEveryNode: Bool = false) {
//    for key in keys {
//      let key = key.lowercased()
//      var currentNode: Trie<T> = self
//      for character in key.utf8 {
//        if let node = currentNode.map[character] {
//          currentNode = node
//        } else {
//          let newNode = Trie<T>()
//          currentNode.map[character] = newNode
//          currentNode = newNode
//        }
//        if addAtEveryNode {
//          currentNode.value.insert(value)
//        }
//      }
//      currentNode.value.insert(value)
//    }
//  }
  
  public mutating func add(value: T, for keys: [String]) {
    for key in keys {
      add(value: value, for: key)
    }
  }
  
  public mutating func add(value: T, for key: String) {
    add(value: value, for: Array(key.utf8))
  }
  
  public mutating func add(value: T, for key: some Collection<UInt8>) {
    if let character = key.first {
      var node = map[character] ?? Trie<T>()
      node.add(value: value, for: key.dropFirst())
      map[character] = node
    } else {
      self.value.insert(value)
    }
  }
  
  public func exactSearch() -> [T]? {
    return nil
  }
  
  public func traverse(searchTerm: String) -> Trie<T>? {
    var node: Trie<T>? = self
    for character in searchTerm.utf8 {
      node = node?.map[character]
    }
    return node
  }
  
  public func allCompletionOptions(for searchTerm: String) -> Set<T> {
    traverse(searchTerm: searchTerm)?.searchAllTrie() ?? []
  }
  
  public func hasMatches(for searchTerm: String) -> Bool {
    let node = traverse(searchTerm: searchTerm)
    return node?.value.isEmpty == false || node?.map.isEmpty == false
  }
  
  public func firstMatch(searchTerm: String) -> T? {
    var node: Trie<T>? = self
    for character in searchTerm.utf8 {
      node = node?.map[character]
      guard let node else { return nil }
      if let value = node.value.first {
        return value
      }
    }
    return nil
  }
  
  public mutating func clear() {
    map = [:]
  }
}
