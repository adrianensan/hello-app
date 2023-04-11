import Foundation

public enum LogLevel: Codable, Comparable, Equatable, Sendable {
  case debug
  case verbose
  case info
  case meta
  case warning
  case error
  case fatal
  case wtf
  
  public var icon: String {
    switch self {
    case .debug: return "curlybraces"
    case .verbose: return "curlybraces"
    case .info: return "info.circle.fill"
    case .meta: return "power"
    case .warning: return "exclamationmark.triangle.fill"
    case .error: return "exclamationmark.octagon.fill"
    case .fatal: return "exclamationmark.octagon.fill"
    case .wtf: return "exclamationmark.octagon.fill"
    }
  }
}
