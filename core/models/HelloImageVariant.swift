import Foundation

public enum HelloImageVariant: Hashable, Sendable, Identifiable {
  case original
  case thumbnail(size: Int)
  
  public var id: String {
    switch self {
    case .original: "original"
    case .thumbnail(let size): "thumbnail-\(size)px"
    }
  }
  
  public var size: Int {
    switch self {
    case .original: 4000
    case .thumbnail(let size): size
    }
  }
}
