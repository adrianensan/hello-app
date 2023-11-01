import Foundation

public struct EmptyResponse: Codable, Sendable {
  public init(from decoder: any Decoder) throws {}
  
  public init() {}
}

public enum RequestType: Codable, Sendable {
  case normal
  case upload
  case longPoll
  case websocket
}

public protocol APIEndpoint: Sendable {
  
  associatedtype RequestBodyType: Codable & Sendable = Data?
  associatedtype ResponseType: Codable & Sendable = EmptyResponse
  
  static var method: HTTPMethod { get }
  var contentType: ContentType? { get }
  var contentTypeBoundary: String? { get }
  var headers: [APIHeader] { get }
  var type: RequestType { get }
  var timeout: TimeInterval { get }
  
  static var path: String { get }
  
  var parameters: [String: String] { get }
  
  var subpath: String? { get }
  
  var body: RequestBodyType { get }
}

extension APIEndpoint {
  
  public var contentType: ContentType? { nil }
  public var contentTypeBoundary: String? { nil }
  
  public var headers: [APIHeader] { [] }
  
  public var type: RequestType { .normal }
  public var timeout: TimeInterval {
    switch type {
    case .normal: return 30
    case .upload: return 100
    case .longPoll: return 120
    case .websocket: return 30
    }
  }
  
  public var body: Data? { nil }
  
  public var subpath: String? { nil }
  
  public var parameters: [String: String] { [:] }
}
