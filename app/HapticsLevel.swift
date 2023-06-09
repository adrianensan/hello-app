import Foundation

public enum HapticsLevel: String, CaseIterable {
  case off
  case minimal
  case normal
  
  public var name: String {
    switch self {
    case .off: return "Off"
    case .minimal: return "Minimal"
    case .normal: return "Normal"
    }
  }
}
