import Foundation

public final class Trie<T: Codable & Hashable>: TrieNode<T>, Sendable {
  
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
  
  public init() {
    super.init()
  }
  
  public init(valueAndKeys: [(T, [String])]) {
    super.init()
    for (value, keys) in valueAndKeys {
      for key in keys {
        var currentNode: TrieNode<T> = self
        for character in key.utf8 {
          if let node = currentNode.map[character] {
            currentNode = node
            continue
          } else {
            let newNode = TrieNode<T>()
            currentNode.map[character] = newNode
            currentNode = newNode
          }
        }
        currentNode.value.insert(value)
      }
    }
  }
  
  public init(valuesMap: [String: T]) {
    super.init()
    for (key, value) in valuesMap {
      var currentNode: TrieNode<T> = self
      for character in key.utf8 {
        if let node = currentNode.map[character] {
          currentNode = node
          continue
        } else {
          let newNode = TrieNode<T>()
          currentNode.map[character] = newNode
          currentNode = newNode
        }
      }
      currentNode.value.insert(value)
    }
  }
  
  required public init(from decoder: any Decoder) throws {
    fatalError("init(from:) has not been implemented")
  }
  
  public func add(value: T, for key: String, addAtEveryNode: Bool = false) {
    add(value: value, for: [key], addAtEveryNode: addAtEveryNode)
  }
  
  public func add(value: T, for keys: [String], addAtEveryNode: Bool = false) {
    for key in keys {
      let key = key.lowercased()
      var currentNode: TrieNode<T> = self
      for character in key.utf8 {
        if let node = currentNode.map[character] {
          currentNode = node
        } else {
          let newNode = TrieNode<T>()
          currentNode.map[character] = newNode
          currentNode = newNode
        }
        if addAtEveryNode {
          currentNode.value.insert(value)
        }
      }
      currentNode.value.insert(value)
    }
  }
  
  public func exactSearch() -> [T]? {
    return nil
  }
  
  public func traverse(searchTerm: String) -> TrieNode<T>? {
    var node: TrieNode<T>? = self
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
    var node: TrieNode<T>? = self
    for character in searchTerm.utf8 {
      node = node?.map[character]
      guard let node else { return nil }
      if let value = node.value.first {
        return value
      }
    }
    return nil
  }
  
  public func clear() {
    map = [:]
  }
}

public class TrieNode<T: Codable & Hashable>: Codable, Sendable {
  
  public internal(set) var value: Set<T>
  public internal(set) var map: [UInt8: TrieNode]
  
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
  
  required public init(from decoder: any Decoder) throws {
    let values = try decoder.container(keyedBy: TrieCodingKeys.self)
    map = try values.decode([UInt8: TrieNode].self, forKey: .map)
    value = try values.decode(Set<T>.self, forKey: .value)
  }
  
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: TrieCodingKeys.self)
    try container.encode(map, forKey: .map)
    try container.encode(value, forKey: .value)
  }
  
  public func searchAllTrie() -> Set<T> {
    var results: Set<T> = Set()
    results.formUnion(value)
    
    for node in map.values {
      results.formUnion(node.searchAllTrie())
    }
    
    return results
  }
  
  public func hasChildren() {
    
  }
}
