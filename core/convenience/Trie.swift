import Foundation

extension Character: Codable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    guard let character = try container.decode(String.self).first else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Decoder expected a Character but found an empty string.")
    }
    self = character
  }
  
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(String(self))
  }
}

public class Trie<T: Codable & Hashable>: TrieNode<T> {
  
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
  
  public func add(value: T, for key: String) {
    add(value: value, for: [key])
  }
  
  public func add(value: T, for keys: [String]) {
    for key in keys {
      let key = key.lowercased()
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
  
  public func clear() {
    map = [:]
  }
}

public class TrieNode<T: Codable & Hashable>: Codable {
  
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
}
