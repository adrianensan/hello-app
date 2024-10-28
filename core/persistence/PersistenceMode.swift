import Foundation

public enum PersistenceMode: String, Codable, Identifiable, CaseIterable, Sendable {
  case normal
  case demo
  case freshInstall
  
  public var id: String { rawValue }
  
  public var name: String {
    switch self {
    case .normal: "Normal"
    case .demo: "Demo"
    case .freshInstall: "New"
    }
  }
}
