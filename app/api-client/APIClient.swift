import Foundation

import HelloCore

public enum APIError: LocalizedError, Sendable {
  case invalidRequest
  case fail
  case duplicate
  case invalidResponse
  case httpError(statusCode: Int)
  
  public var errorDescription: String? {
    switch self {
    case .invalidRequest: return "Invalid HTTP Request"
    case .fail: return "Fail"
    case .duplicate: return "Duplicate request"
    case .invalidResponse: return "Invalid Response"
    case .httpError(let statusCode): return "HTTP Error \(statusCode)"
    }
  }
}

public struct OFAPIResponse<Content: Decodable & Sendable>: Sendable {
  public var headers: [String: String]
  public var content: Content
}

//public class WebSocketsSession: NSObject {
//
//  private var session: URLSessionWebSocketTask
//
//  public init(session: URLSessionWebSocketTask) {
//    self.session = session
//  }
//
//  public func send(data: Data) async throws {
//    do {
//      try await session.send(.data(data))
//    } catch {
//      if let httpURLResponse = (session.response as? HTTPURLResponse),
//         !HTTPResponseStatus.from(code: httpURLResponse.statusCode).isSuccess {
//        throw APIError.httpError(statusCode: httpURLResponse.statusCode)
//      } else {
//        throw error
//      }
//    }
//  }
//
//  public var data: AsyncThrowingStream<Data, Error> {
//    AsyncThrowingStream { continuation in
//      Task {
//        do {
//          while true {
//            let rawMessage = try await session.receive()
//            switch rawMessage {
//            case .data(let data):
//              continuation.yield(data)
//            case .string(let string): ()
//            }
//          }
//        } catch {
//          if let httpResponse = (session.response as? HTTPURLResponse) {
//            continuation.finish(throwing: APIError.httpError(statusCode: httpResponse.statusCode))
//          } else {
//            print(session.closeCode)
//            continuation.finish(throwing: error)
//          }
//        }
//      }
//    }
//  }
//}

public protocol TestAPIClient: Actor {
  var apiRoot: String { get }
  
  var session: URLSession { get }
  
  var userAgentString: String { get }
  
  func additionalHeaders(endpoint: some APIEndpoint) -> [String: String]
  
  func handle(headers: [AnyHashable: Any], for endpoint: some APIEndpoint)
  
  func handle(errorResponse response: HTTPResponse<Data?>) async throws
}

public extension TestAPIClient {
  var userAgentString: String { "\(App.displayName); \(AppVersion.current?.description ?? "?"); \(OSInfo.description); \(Device.current.description)" }
  
  func additionalHeaders(endpoint: some APIEndpoint) -> [String: String] { [:] }
  
  func handle(headers: [AnyHashable: Any], for endpoint: some APIEndpoint) {}
  
  func handle(errorResponse response: HTTPResponse<Data?>) async throws {}
  
  private func urlPath<Endpoint: APIEndpoint>(for endpoint: Endpoint) -> String {
    var urlString: String = Endpoint.path
    if let actualSubpath = endpoint.subpath {
      urlString += "/" + actualSubpath
    }
    
    if !endpoint.parameters.isEmpty {
      urlString += "?"
      for (i, (key, value)) in endpoint.parameters.enumerated() {
        if i > 0 {
          urlString += "&"
        }
        urlString += "\(key)=\(value)"
      }
    }
    return urlString
  }
  
  private func request<Endpoint: APIEndpoint>(for endpoint: Endpoint) throws -> URLRequest {
    var subpath: String = urlPath(for: endpoint)
    
    var apiRoot = apiRoot
    if endpoint.type == .websocket {
      apiRoot = apiRoot.replacingOccurrences(of: "https", with: "wss")
    }
    
    guard let url = URL(string: apiRoot + subpath) else {
      throw APIError.invalidRequest
    }
    
    let bodyData: Data?
    let inferredContentType: ContentType?
    if let data = endpoint.body as? Data? {
      bodyData = data
      inferredContentType = nil
    } else if let string = endpoint.body as? String? {
      bodyData = string?.data(using: .utf8)
      inferredContentType = .plain
    } else {
      bodyData = try? JSONEncoder().encode(endpoint.body)
      inferredContentType = .json
    }
    
    return URLRequest(url: url) +& {
      $0.httpBody = bodyData
      switch endpoint.type {
      case .normal, .longPoll, .websocket: ()
      case .upload:
        $0.allowsExpensiveNetworkAccess = true
        $0.allowsConstrainedNetworkAccess = true
      }
      $0.timeoutInterval = endpoint.timeout
      $0.httpMethod = Endpoint.method.description
      if let contentType = endpoint.contentType ?? inferredContentType {
        var contentTypeString = contentType.typeString
        if let boundary = endpoint.contentTypeBoundary {
          contentTypeString += "; boundary=\(boundary)"
        }
        $0.setValue(contentTypeString, forHTTPHeaderField: "Content-Type")
      }
      $0.setValue(userAgentString, forHTTPHeaderField: "User-Agent")
      for header in endpoint.headers {
        $0.setValue(header.value, forHTTPHeaderField: header.key)
      }
      for (key, value) in additionalHeaders(endpoint: endpoint) {
        $0.setValue(value, forHTTPHeaderField: key)
      }
    }
  }
  
  @discardableResult
  public func request<Endpoint: APIEndpoint>(endpoint: Endpoint,
                                             isRetry: Bool = false,
                                             retryHandler: (@Sendable (APIError) async throws -> Bool)? = nil,
                                             uploadProgressUpdate: (@Sendable (Double) -> Bool)? = nil) async throws -> OFAPIResponse<Endpoint.ResponseType> {
    let requestStartTime = Date().timeIntervalSince1970
    var logStart = Endpoint.method.description + " " + urlPath(for: endpoint)
    
    let request = try request(for: endpoint)
    
    let (data, urlResponse): (Data, URLResponse)
    switch endpoint.type {
    case .normal, .longPoll:
      do {
        (data, urlResponse) = try await session.data(for: request)
      } catch {
        let requestDuration = Date().timeIntervalSince1970 - requestStartTime
        logStart += String(format: " (%.2fs)", requestDuration)
        Log.error("\(logStart) failed with error: \(error.localizedDescription)", context: "API")
        throw error
      }
    case .upload:
      guard let bodyData = request.httpBody else {
        Log.error("\(logStart) Request body empty for expected upload", context: "API")
        throw APIError.invalidRequest
      }
      var delegate: OFAPIUploadTaskDelegate?
      if let progressUpdater = uploadProgressUpdate {
        delegate = OFAPIUploadTaskDelegate(progressUpdater: progressUpdater)
      }
      do {
        (data, urlResponse) = try await session.upload(for: request, from: bodyData, delegate: delegate)
      } catch {
        let requestDuration = Date().timeIntervalSince1970 - requestStartTime
        logStart += String(format: " (%.2fs)", requestDuration)
        Log.error("\(logStart) failed with error: \(error.localizedDescription)", context: "API")
        throw error
      }
    case .websocket:
      do {
        let wsSession = session.webSocketTask(with: request)
        throw APIError.invalidRequest
      } catch {
        let requestDuration = Date().timeIntervalSince1970 - requestStartTime
        logStart += String(format: " (%.2fs)", requestDuration)
        Log.error("\(logStart) failed with error: \(error.localizedDescription)", context: "API")
        throw error
      }
    }
    let requestDuration = Date().timeIntervalSince1970 - requestStartTime
    logStart += String(format: " (%.2fs)", requestDuration)
    
    guard let httpResponse = urlResponse as? HTTPURLResponse else {
      Log.error("\(logStart) failed", context: "API")
      throw APIError.fail
    }
    
    logStart += " \(httpResponse.statusCode)"
    
    let response: HTTPResponse<Data?> = HTTPResponse<Data?>(httpURLResponse: httpResponse, data: data)
    
    guard response.status.isSuccess else {
      Log.error("\(logStart)", context: "API")
      try await handle(errorResponse: response)
      let error = APIError.httpError(statusCode: httpResponse.statusCode)
      if !isRetry, try await retryHandler?(error) == true {
        Log.info("\(Endpoint.path) retrying", context: "API")
        return try await self.request(endpoint: endpoint, isRetry: true, retryHandler: retryHandler)
      } else {
        throw error
      }
    }
    
    let headers: [String: String] = [:]
    
    handle(headers: httpResponse.allHeaderFields, for: endpoint)
    
    switch Endpoint.ResponseType.self {
    case is EmptyResponse.Type:
      guard let decodedResponse = EmptyResponse() as? Endpoint.ResponseType else {
        Log.error("\(logStart) failed to decode response", context: "API")
        throw APIError.invalidResponse
      }
      Log.info("\(logStart)", context: "API")
      return OFAPIResponse(headers: headers, content: decodedResponse)
    case is Data.Type:
      guard let decodedResponse = data as? Endpoint.ResponseType else {
        Log.error("\(logStart) failed to decode response", context: "API")
        throw APIError.invalidResponse
      }
      Log.info("\(logStart)", context: "API")
      return OFAPIResponse(headers: headers, content: decodedResponse)
    case is String.Type:
      guard let decodedResponse = String(data: data, encoding: .utf8) as? Endpoint.ResponseType else {
        Log.error("\(logStart) failed to decode response", context: "API")
        throw APIError.invalidResponse
      }
      Log.info("\(logStart)", context: "API")
      return OFAPIResponse(headers: headers, content: decodedResponse)
    default:
      guard let decodedResponse = try? JSONDecoder().decode(Endpoint.ResponseType.self, from: data) else {
        if let stringResponse = String(data: data, encoding: .utf8) {
          Log.debug(stringResponse, context: "API error")
        }
        Log.error("\(logStart) failed to decode response", context: "API")
        throw APIError.invalidResponse
      }
      Log.info("\(logStart)", context: "API")
      return OFAPIResponse(headers: headers, content: decodedResponse)
    }
  }
  
  public func websocketsSession<Endpoint: APIEndpoint>(endpoint: Endpoint) throws -> URLSessionWebSocketTask {
    let urlRequest = try request(for: endpoint)
    let requestStartTime = Date().timeIntervalSince1970
    var logStart = Endpoint.path
    
    let session = session.webSocketTask(with: urlRequest)
    
    let requestDuration = Date().timeIntervalSince1970 - requestStartTime
    logStart += String(format: " (%.2fs)", requestDuration)
    Log.info("\(logStart)", context: "API")
    
    return session
  }
}

class OFAPIUploadTaskDelegate: NSObject, URLSessionTaskDelegate {
  
  let progressUpdater: (Double) -> Bool
  
  init(progressUpdater: @escaping (Double) -> Bool) {
    self.progressUpdater = progressUpdater
  }
  
  public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
    let shouldContinue = progressUpdater(Double(totalBytesSent) / Double(max(1, totalBytesExpectedToSend)))
    if !shouldContinue {
      task.cancel()
    }
  }
}
