import Foundation

import HelloCore

public actor Downloader {
  
  public static let main: Downloader = Downloader()
  
  private var _session: URLSession?
  private var session: URLSession {
    _session ?? URLSession(
      configuration: URLSessionConfiguration.default +& {
        $0.allowsCellularAccess = true
        $0.timeoutIntervalForRequest = 100
        $0.waitsForConnectivity = false
        $0.tlsMinimumSupportedProtocolVersion = .TLSv12
        $0.tlsMaximumSupportedProtocolVersion = .TLSv13
        $0.allowsExpensiveNetworkAccess = true
        $0.allowsConstrainedNetworkAccess = true
        $0.httpAdditionalHeaders = ["User-Agent": "\(App.displayName) iOS v\(AppVersion.current?.display ?? "?"); \(Device.current.description); \(OSInfo.description)"]
      },
      delegate: nil,
      delegateQueue: nil
    ) +& { _session = $0 }
  }
  
  private var downloadingURLs: Set<URL> = []
  
  public init() {}
  
  public func download(from urlString: String, downloadProgressUpdate: (@Sendable (Double) -> Void)? = nil) async throws -> Data {
    guard let url = URLComponents(string: urlString)?.url else {
      throw APIError.invalidURL
    }
    return try await download(from: url, downloadProgressUpdate: downloadProgressUpdate)
  }
  
  public func download(from url: URL, downloadProgressUpdate: (@Sendable (Double) -> Void)? = nil) async throws -> Data {
    guard !downloadingURLs.contains(url) else { throw APIError.duplicate }
    downloadingURLs.insert(url)
    defer { downloadingURLs.remove(url) }
    let requestStartTime = Date().timeIntervalSince1970
    var logStart = url.absoluteString.removingPercentEncoding ?? url.absoluteString
    
    let (data, urlResponse): (Data, URLResponse)
    do {
      var delegate: OFAPIDownloadTaskDelegate?
      if let progressUpdater = downloadProgressUpdate {
        delegate = OFAPIDownloadTaskDelegate(progressUpdater: progressUpdater)
      }
      (data, urlResponse) = try await session.data(from: url, delegate: delegate)
    } catch {
      let requestDuration = Date().timeIntervalSince1970 - requestStartTime
      logStart += String(format: " (%.2fs)", requestDuration)
      Log.error("\(logStart) failed with error: \(error.localizedDescription)", context: "Downloader")
      throw error
    }
    let requestDuration = Date().timeIntervalSince1970 - requestStartTime
    logStart += String(format: " (%.2fs)", requestDuration)
    
    guard let httpResponse = urlResponse as? HTTPURLResponse else {
      Log.error("\(logStart) failed", context: "Downloader")
      throw APIError.fail
    }
    
    logStart += " \(httpResponse.statusCode)"
    
    guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
      Log.error("\(logStart)", context: "Downloader")
      throw APIError.httpError(statusCode: httpResponse.statusCode)
    }
    
    Log.info("\(logStart)", context: "Downloader")
    return data
  }
}

class OFAPIDownloadTaskDelegate: NSObject, URLSessionDataDelegate {
  
  let progressUpdater: (Double) -> Void
  
  init(progressUpdater: @escaping (Double) -> Void) {
    self.progressUpdater = progressUpdater
  }
  
  public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    progressUpdater(Double(dataTask.countOfBytesReceived) / Double(dataTask.countOfBytesExpectedToReceive))
  }
}
