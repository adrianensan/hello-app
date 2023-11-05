//import Foundation
//
//public protocol HelloAPIClient: Actor {
//  var scheme: String { get }
//  
//  var host: String { get }
//  
//  var session: URLSession { get }
//  
//  var userAgentString: String { get }
//  
//  func additionalHeaders(endpoint: some APIEndpoint) -> [String: String]
//  
//  func handle(headers: [AnyHashable: Any], for endpoint: some APIEndpoint)
//  
//  func handle(errorResponse response: HTTPResponse<Data?>) async throws
//}
