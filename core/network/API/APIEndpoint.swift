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
//  associatedtype APIClient: HelloAPIClient
  
  static var path: String { get }
  static var method: HTTPMethod { get }
  
//  var client: APIClient { get }
  var scheme: APIEndpointScheme { get }
  var host: String { get }
  var method: HTTPMethod { get }
  var contentType: ContentType? { get }
  var contentTypeBoundary: String? { get }
  var headers: [APIHeader] { get }
  var type: RequestType { get }
  var timeout: TimeInterval { get }
  
  var path: String { get }
  
  var parameters: [String: String] { get }
  
  var body: RequestBodyType { get }
}

extension APIEndpoint {
  
  static var path: String { "" }
  var path: String { Self.path }
  
  static var method: HTTPMethod { .get }
  var method: HTTPMethod { Self.method }
  
  public var scheme: APIEndpointScheme { .https }
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
  
  public var parameters: [String: String] { [:] }
  
  public var urlString: String {
    var urlString: String = "\(scheme)://\(host)\(path)"
    
    if !parameters.isEmpty {
      urlString += "?"
      for (i, (key, value)) in parameters.enumerated() {
        if i > 0 {
          urlString += "&"
        }
        urlString += "\(key)=\(value)"
      }
    }
    return urlString
  }
}
