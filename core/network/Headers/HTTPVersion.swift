public enum HTTPVersion: CustomStringConvertible, Sendable {
  case http1_0
  case http1_1
  case http2_0
  
  private static let baseString = "HTTP/"
  
  public var description: String {
    switch self {
    case .http1_0: HTTPVersion.baseString + "1.0"
    case .http1_1: HTTPVersion.baseString + "1.1"
    case .http2_0: HTTPVersion.baseString + "2.0"
    }
  }
}
