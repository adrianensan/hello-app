public enum HTTPMethod: CustomStringConvertible, Codable, Sendable {
  case get
  case head
  case post
  case put
  case delete
  case patch
  case options
  case any
  case unknown
  
  public static func infer(from string: String) -> HTTPMethod {
    switch string.lowercased() {
    case "get": .get
    case "head": .head
    case "post": .post
    case "put": .put
    case "delete": .delete
    case "patch": .patch
    case "options": .options
    default: .unknown
    }
  }
  
  public var description: String {
    switch self {
    case .get: "GET"
    case .head: "HEAD"
    case .post: "POST"
    case .put: "PUT"
    case .delete: "DELETE"
    case .patch: "PATCH"
    case .options: "OPTIONS"
    default: "UNKNOWN"
    }
  }
}
