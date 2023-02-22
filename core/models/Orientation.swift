import Foundation

public enum Orientation: String, Equatable, Hashable, Codable, Identifiable, Sendable {
  case vertical
  case horizontal
  
  public var id: String { rawValue }
  
  public var name: String {
    switch self {
    case .vertical: return "Vertical"
    case .horizontal: return "Horizontal"
    }
  }
}
