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

open class APIClient {
  
  public var apiRoot: String
  
  private let userAgentString = "\(App.displayName); \(AppVersion.current?.description ?? "?"); \(OSInfo.description); \(Device.current.description)"
  
  private var _session: URLSession?
  private var session: URLSession {
    _session ?? URLSession(
      configuration: URLSessionConfiguration.default +& {
        $0.allowsCellularAccess = true
        $0.timeoutIntervalForRequest = 20
        $0.waitsForConnectivity = false
        $0.tlsMinimumSupportedProtocolVersion = .TLSv12
        $0.tlsMaximumSupportedProtocolVersion = .TLSv13
        $0.allowsExpensiveNetworkAccess = true
        $0.allowsConstrainedNetworkAccess = true
      },
      delegate: nil,
      delegateQueue: nil
    ) +& { _session = $0 }
  }
  
  public init(apiRoot: String) {
    self.apiRoot = apiRoot
  }
  
  open func additionalHeaders(endpoint: some APIEndpoint) -> [String: String] {
    [:]
  }
  
  open func handle(headers: [AnyHashable: Any], for endpoint: some APIEndpoint) {
    
  }
  
  open func handle(errorResponse response: HTTPResponse<Data?>) throws {
    
  }
  
  func request<Endpoint: APIEndpoint>(for endpoint: Endpoint) throws -> URLRequest {
    var subpath: String = ""
    if let actualSubpath = endpoint.subpath {
      subpath += "/" + actualSubpath
    }
    
    var parameters: String = ""
    if !endpoint.parameters.isEmpty {
      parameters += "?"
      for (key, value) in endpoint.parameters {
        if parameters.count > 2 {
          parameters += "&"
        }
        parameters += "\(key)=\(value)"
      }
    }
    
    var apiRoot = apiRoot
    if endpoint.type == .websocket {
      apiRoot = apiRoot.replacingOccurrences(of: "https", with: "wss")
    }
    
    guard let url = URL(string: apiRoot + Endpoint.path + subpath + parameters) else {
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
      switch endpoint.type {
      case .normal, .longPoll, .websocket:
        $0.httpBody = bodyData
      case .upload:
        $0.httpBody = bodyData
        $0.allowsExpensiveNetworkAccess = true
        $0.allowsConstrainedNetworkAccess = true
      }
      $0.timeoutInterval = endpoint.timeout
      $0.httpMethod = Endpoint.method.description
      if let contentType = endpoint.contentType ?? inferredContentType {
        $0.setValue(contentType.typeString, forHTTPHeaderField: "Content-Type")
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
  
//  public func websocketsSession<Endpoint: APIEndpoint>(endpoint: Endpoint) throws -> WebSocketsSession {
//    let urlRequest = try request(for: endpoint)
//    let requestStartTime = Date().timeIntervalSince1970
//    var logStart = Endpoint.path
//    
//    let session = session.webSocketTask(with: urlRequest)
//    session.resume()
//    
//    let requestDuration = Date().timeIntervalSince1970 - requestStartTime
//    logStart += String(format: " (%.2fs)", requestDuration)
//    Log.info("\(logStart)", context: "API")
//    
//    return WebSocketsSession(session: session)
//  }
  
  @discardableResult
  public func request<Endpoint: APIEndpoint>(endpoint: Endpoint,
                                             isRetry: Bool = false,
                                             retryHandler: (@Sendable (APIError) async throws -> Bool)? = nil,
                                             uploadProgressUpdate: (@Sendable (Double) -> Bool)? = nil) async throws -> OFAPIResponse<Endpoint.ResponseType> {
    let requestStartTime = Date().timeIntervalSince1970
    var logStart = Endpoint.method.description + " " + Endpoint.path
    if let actualSubpath = endpoint.subpath {
      logStart += "/" + actualSubpath
    }
    
    if !endpoint.parameters.isEmpty {
      logStart += "?"
      var isFirst = true
      for (key, value) in endpoint.parameters {
        if !isFirst {
          logStart += "&"
        }
        isFirst = false
        logStart += "\(key)=\(value)"
      }
    }

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
    
    let response: HTTPResponse<Data?> = HTTPResponse(status: .from(code: httpResponse.statusCode), body: data)
    
    guard response.status.isSuccess else {
      Log.error("\(logStart)", context: "API")
      try handle(errorResponse: response)
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
