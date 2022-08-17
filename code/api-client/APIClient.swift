import Foundation

import HelloCore

public enum APIError: Error {
  case invalidRequest
  case fail
  case duplicate
  case invalidResponse
  case httpError(statusCode: Int)
}

public struct OFAPIResponse<Content: Decodable> {
  public var headers: [String: String]
  public var content: Content
}

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
  
  open var errorHandlers: [Int: (HTTPResponse<Data?>) -> Void] { [:] }
  
  @discardableResult
  public func request<Endpoint: APIEndpoint>(endpoint: Endpoint,
                                             isRetry: Bool = false,
                                             retryHandler: ((APIError) async throws -> Bool)? = nil,
                                             uploadProgressUpdate: ((Double) -> Bool)? = nil) async throws -> OFAPIResponse<Endpoint.ResponseType> {
    let requestStartTime = Date().timeIntervalSince1970
    var logStart = Endpoint.path
    
    guard let url = URL(string: apiRoot + Endpoint.path) else {
      throw APIError.invalidRequest
    }
    
    let bodyData: Data?
    if let data = endpoint.body as? Data? {
      bodyData = data
    } else if let string = endpoint.body as? String? {
      bodyData = string?.data(using: .utf8)
    } else {
      bodyData = try? JSONEncoder().encode(endpoint.body)
    }
    
    let request = URLRequest(url: url) +& {
      switch endpoint.type {
      case .normal, .longPoll:
        $0.httpBody = bodyData
      case .upload:
        $0.allowsExpensiveNetworkAccess = true
        $0.allowsConstrainedNetworkAccess = true
      }
      $0.timeoutInterval = endpoint.timeout
      $0.httpMethod = Endpoint.method.description
      if let contentType = endpoint.contentType {
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
      guard let bodyData = bodyData else {
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
    }
    let requestDuration = Date().timeIntervalSince1970 - requestStartTime
    logStart += String(format: " (%.2fs)", requestDuration)
    
    guard let httpResponse = urlResponse as? HTTPURLResponse else {
      Log.error("\(logStart) failed", context: "API")
      throw APIError.fail
    }
    
    logStart += " \(httpResponse.statusCode)"
    
    guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
      if let handler = errorHandlers[httpResponse.statusCode] {
        handler(HTTPResponse(status: .from(code: httpResponse.statusCode), body: data))
      }
      let error = APIError.httpError(statusCode: httpResponse.statusCode)
      Log.error("\(logStart)", context: "API")
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
