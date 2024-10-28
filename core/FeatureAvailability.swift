import Foundation

public enum FeatureAvailability: String, Sendable {
  case free
  case paid
  case hidden
  
  public var isAlwaysVisible: Bool {
    switch self {
    case .free: true
    case .paid: true
    case .hidden: false
    }
  }
  
  public var isAlwaysAvailable: Bool {
    switch self {
    case .free: true
    case .paid: false
    case .hidden: true
    }
  }
}
