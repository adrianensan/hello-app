import Foundation

public enum HapticsLevel: String, Identifiable, CaseIterable {
  case off
  case minimal
  case normal
  
  public var id: String { rawValue }
  
  public var name: String {
    switch self {
    case .off: return "Off"
    case .minimal: return "Minimal"
    case .normal: return "Normal"
    }
  }
}
