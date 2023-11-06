import Foundation

public enum HelloFont: Codable, Sendable, Hashable {
  
  case rounded
  case normal
  case mono
  case custom(String)
}
