import Foundation

import HelloCore

public enum APIError: LocalizedError, Sendable {
  case invalidURL
  case invalidRequest
  case fail
  case duplicate
  case invalidResponse
  case httpError(statusCode: Int)
  
  public var errorDescription: String? {
    switch self {
    case .invalidURL: "Invalid URL"
    case .invalidRequest: "Invalid HTTP Request"
    case .fail: "Fail"
    case .duplicate: "Duplicate request"
    case .invalidResponse: "Invalid Response"
    case .httpError(let statusCode): "HTTP Error \(statusCode)"
    }
  }
}

public struct HelloAPIResponse<Content: Decodable & Sendable>: Sendable {
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

@HelloAPIActor
public protocol HelloAPIClient {
  var session: URLSession { get }
  
  var userAgentString: String { get }
  
  func additionalHeaders(endpoint: some APIEndpoint) -> [String: String]
  
  func handle(headers: [AnyHashable: Any], for endpoint: some APIEndpoint)
  
  func handle(errorResponse response: HTTPResponse<Data?>) async throws
}

public extension HelloAPIClient {
  
  var userAgentString: String { "\(AppInfo.displayName); \(AppVersion.current?.description ?? "?"); \(OSInfo.description); \(Device.current.description)" }
  
  func additionalHeaders(endpoint: some APIEndpoint) -> [String: String] { [:] }
  
  func handle(headers: [AnyHashable: Any], for endpoint: some APIEndpoint) {}
  
  func handle(errorResponse response: HTTPResponse<Data?>) async throws {}
  
  private func request(for endpoint: some APIEndpoint) throws -> URLRequest {
    var urlComponents = URLComponents()
    urlComponents.scheme = endpoint.scheme.rawValue
    urlComponents.host = endpoint.host
    urlComponents.path = endpoint.path
    urlComponents.queryItems = endpoint.parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    
    guard let url = urlComponents.url else {
      throw HelloError("Invalid url \(endpoint.urlString)")
    }
    
    let bodyData: Data?
    let inferredContentType: ContentType?
    if let data = endpoint.body as? Data? {
      bodyData = data
      inferredContentType = nil
    } else if let string = endpoint.body as? String? {
      bodyData = string?.data
      inferredContentType = .plain
    } else {
      do {
        bodyData = try endpoint.body.prettyJSONData
      } catch {
        throw HelloError("Failed to encode body for \(endpoint.urlString)")
      }
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
      $0.httpMethod = endpoint.method.description
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
  func request<Endpoint: APIEndpoint>(endpoint: Endpoint,
                                      isRetry: Bool = false,
                                      retryHandler: (@Sendable (APIError) async throws -> Bool)? = nil,
                                      uploadProgressUpdate: (@Sendable (Double) -> Bool)? = nil) async throws -> HelloAPIResponse<Endpoint.ResponseType> {
    let requestStartTime = epochTime
    
    var request: URLRequest
    do {
      request = try self.request(for: endpoint)
    } catch {
      Log.error(context: "API", error.localizedDescription)
      throw error
    }
    
    @Sendable func logStatement(for endpoint: some APIEndpoint, duration: TimeInterval? = nil, statusCode: Int? = nil) -> String {
      var logStatement = endpoint.method.description + " " + endpoint.urlString
      if let duration {
        logStatement += String(format: " (%.2fs)", duration)
      }
      if let statusCode {
        logStatement += " \(statusCode)"
      }
      return logStatement
    }
    
    let (data, urlResponse): (Data, URLResponse)
    switch endpoint.type {
    case .normal, .longPoll:
      do {
        (data, urlResponse) = try await session.data(for: request)
      } catch {
        let requestDuration = epochTime - requestStartTime
        Log.error(context: "API", "\(logStatement(for: endpoint, duration: requestDuration)) failed with error: \(error.localizedDescription)")
        throw error
      }
    case .upload:
      guard let bodyData = request.httpBody else {
        Log.error(context: "API", "\(logStatement(for: endpoint)) Request body empty for expected upload")
        throw APIError.invalidRequest
      }
      var delegate: HelloAPIUploadTaskDelegate?
      if let progressUpdater = uploadProgressUpdate {
        delegate = HelloAPIUploadTaskDelegate(progressUpdater: progressUpdater)
      }
      do {
        request.httpBody = nil
        (data, urlResponse) = try await session.upload(for: request, from: bodyData, delegate: delegate)
      } catch {
        let requestDuration = epochTime - requestStartTime
        Log.error(context: "API", "\(logStatement(for: endpoint, duration: requestDuration)) failed with error: \(error.localizedDescription)")
        throw error
      }
    case .websocket:
      do {
        let wsSession = session.webSocketTask(with: request)
        throw APIError.invalidRequest
      } catch {
        let requestDuration = epochTime - requestStartTime
        Log.error(context: "API", "\(logStatement(for: endpoint, duration: requestDuration)) failed with error: \(error.localizedDescription)")
        throw error
      }
    }
    let requestDuration = epochTime - requestStartTime
    
    guard let httpResponse = urlResponse as? HTTPURLResponse else {
      Log.error(context: "API", "\(logStatement(for: endpoint, duration: requestDuration)) failed")
      throw APIError.fail
    }
    
    let statusCode = httpResponse.statusCode
    
    let response: HTTPResponse<Data?> = HTTPResponse<Data?>(httpURLResponse: httpResponse, data: data)
    
    guard response.status.isSuccess else {
      if let bodyString = (response.body as? String) ?? (try? String.decodeJSON(from: data)) {
        Log.error(context: "API", "\(logStatement(for: endpoint, duration: requestDuration, statusCode: statusCode))\n\(bodyString)")
      } else {
        Log.error(context: "API", "\(logStatement(for: endpoint, duration: requestDuration, statusCode: statusCode))")
      }
      try await handle(errorResponse: response)
      let error = APIError.httpError(statusCode: httpResponse.statusCode)
      if !isRetry, try await retryHandler?(error) == true {
        Log.info(context: "API", "\(endpoint.path) retrying")
        return try await self.request(endpoint: endpoint, isRetry: true, retryHandler: retryHandler)
      } else {
        throw error
      }
    }
    
    var headers: [String: String] = [:]
    
    for (key, value) in httpResponse.allHeaderFields {
      if let keyString = key as? String, let valueString = value as? String {
        headers[keyString.lowercased()] = valueString
      }
    }
    
    handle(headers: httpResponse.allHeaderFields, for: endpoint)
    
    switch Endpoint.ResponseType.self {
    case is EmptyResponse.Type:
      guard let decodedResponse = EmptyResponse() as? Endpoint.ResponseType else {
        Log.error(context: "API", "\(logStatement(for: endpoint, duration: requestDuration, statusCode: statusCode)) failed to decode response")
        throw APIError.invalidResponse
      }
      Log.info(context: "API", "\(logStatement(for: endpoint, duration: requestDuration, statusCode: statusCode))")
      return HelloAPIResponse(headers: headers, content: decodedResponse)
    case is Data.Type:
      guard let decodedResponse = data as? Endpoint.ResponseType else {
        Log.error(context: "API", "\(logStatement(for: endpoint, duration: requestDuration, statusCode: statusCode)) failed to decode response")
        throw APIError.invalidResponse
      }
      Log.info(context: "API", "\(logStatement(for: endpoint, duration: requestDuration, statusCode: statusCode))")
      return HelloAPIResponse(headers: headers, content: decodedResponse)
    case is String.Type:
      guard let decodedResponse = String(data: data, encoding: .utf8) as? Endpoint.ResponseType else {
        Log.error(context: "API", "\(logStatement(for: endpoint, duration: requestDuration, statusCode: statusCode)) failed to decode response")
        throw APIError.invalidResponse
      }
      Log.info(context: "API", "\(logStatement(for: endpoint, duration: requestDuration, statusCode: statusCode))")
      return HelloAPIResponse(headers: headers, content: decodedResponse)
    default:
      guard let decodedResponse = try? Endpoint.ResponseType.decodeJSON(from: data) else {
        Log.error(context: "API", "\(logStatement(for: endpoint, duration: requestDuration, statusCode: statusCode)) failed to decode response")
        if let stringResponse = String(data: data, encoding: .utf8) {
          Log.debug(stringResponse)
        }
        throw APIError.invalidResponse
      }
      Log.info(context: "API", "\(logStatement(for: endpoint, duration: requestDuration, statusCode: statusCode))")
      return HelloAPIResponse(headers: headers, content: decodedResponse)
    }
  }
  
  func stream<Endpoint: APIEndpoint>(from endpoint: Endpoint) async throws -> AsyncThrowingStream<Endpoint.ResponseType, any Error> {
    var request: URLRequest
    do {
      request = try self.request(for: endpoint)
    } catch {
      Log.error(context: "API", error.localizedDescription)
      throw error
    }
    let (stream, urlResponse) = try await session.bytes(for: request)
    return AsyncThrowingStream(Endpoint.ResponseType.self) { continuation in
      Task {
        do {
//          for try await byte in stream {
//            if let chunk = try? JSONDecoder().decode(Endpoint.ResponseType.self, from: byte) {
//              continuation.yield(chunk)
//            }
//          }
          for try await line in stream.lines {
            let components = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            guard components.count == 2, components[0] == "data" else {
              if let chunk = try? Endpoint.ResponseType.decodeJSON(from: line.data) {
                continuation.yield(chunk)
              }
              continue
            }
            
            let message = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            
            if message == "[DONE]" {
              continuation.finish()
              return
            } else if let chunk = try? Endpoint.ResponseType.decodeJSON(from: message.data) {
              continuation.yield(chunk)
            }
          }
          continuation.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }
    }
  }
  
  func websocketsSession<Endpoint: APIEndpoint>(endpoint: Endpoint) throws -> URLSessionWebSocketTask {
    let urlRequest = try request(for: endpoint)
    let requestStartTime = epochTime
    
    let session = session.webSocketTask(with: urlRequest)
    session.maximumMessageSize = 3145728
    
    let requestDuration = epochTime - requestStartTime
    Log.info(context: "API", "\(endpoint.path + String(format: " (%.2fs)", requestDuration))")
    
    return session
  }
}

final class HelloAPIUploadTaskDelegate: NSObject, URLSessionTaskDelegate {
  
  let progressUpdater: @Sendable (Double) -> Bool
  
  init(progressUpdater: @escaping @Sendable (Double) -> Bool) {
    self.progressUpdater = progressUpdater
  }
  
  public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
    let shouldContinue = progressUpdater(Double(totalBytesSent) / Double(max(1, totalBytesExpectedToSend)))
    if !shouldContinue {
      task.cancel()
    }
  }
}
