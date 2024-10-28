import Foundation

public enum LogLevel: Codable, Comparable, Equatable, Sendable, CaseIterable {
  case debug
  case verbose
  case info
  case meta
  case warning
  case error
  case fatal
  case wtf
  
  public var name: String {
    switch self {
    case .debug: "Debug"
    case .verbose: "Verbose"
    case .info: "Info"
    case .meta: "Meta"
    case .warning: "Warning"
    case .error: "Error"
    case .fatal: "Fatal"
    case .wtf: "WTF"
    }
  }
  
  public var icon: String {
    switch self {
    case .debug: "curlybraces"
    case .verbose: "curlybraces"
    case .info: "info"
    case .meta: "power"
    case .warning: "exclamationmark.triangle.fill"
    case .error: "exclamationmark.octagon.fill"
    case .fatal: "exclamationmark.octagon.fill"
    case .wtf: "exclamationmark.octagon.fill"
    }
  }
}
