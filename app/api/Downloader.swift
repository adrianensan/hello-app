import Foundation
//import CFNetwork

import HelloCore

public enum HelloDownloadError: Error {
  case duplicate
  case noInternet
  case noHTTPResponse
  case noFile
  case httpError(code: HTTPResponseStatus)
  case nsURLError(code: Int)
  case cfNetworkError(code: Int)
  case other(any Error)
}

@globalActor final public actor HelloAPIActor: GlobalActor {
  public static let shared: HelloAPIActor = HelloAPIActor()
}

@HelloAPIActor
public class Downloader {
  
  @HelloAPIActor
  final class HelloAPIDownloadTaskDelegate: NSObject, URLSessionDownloadDelegate {
    
    var continuation: CheckedContinuation<(URL, URLResponse), any Error>?
    let progressUpdater: @Sendable (Double) -> Void
    
    init(continuation: CheckedContinuation<(URL, URLResponse), any Error>, progressUpdater: @escaping @Sendable (Double) -> Void) {
      self.continuation = continuation
      self.progressUpdater = progressUpdater
    }
    
    nonisolated func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
      Task { progressUpdater(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)) }
    }
    
    nonisolated func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
      if let urlResponse = downloadTask.response {
        Task { await finished(url: location, urlResponse: urlResponse) }
      } else {
        Task { await failed(error: HelloError("No response")) }
      }
    }
    
    nonisolated func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
      Task { await failed(error: error ?? HelloError("Error")) }
    }
    
    func finished(url: URL, urlResponse: URLResponse) {
      continuation?.resume(returning: (url, urlResponse))
      continuation = nil
    }
    
    func failed(error: any Error) {
      continuation?.resume(throwing: error)
      continuation = nil
    }
  }
  
  public static let main = Downloader()
  
  private let session: URLSession = URLSession(
    configuration: URLSessionConfiguration.ephemeral +& {
        $0.allowsCellularAccess = true
        $0.timeoutIntervalForRequest = 100
        $0.waitsForConnectivity = false
        $0.tlsMinimumSupportedProtocolVersion = .TLSv12
        $0.tlsMaximumSupportedProtocolVersion = .TLSv13
        $0.allowsExpensiveNetworkAccess = true
        $0.allowsConstrainedNetworkAccess = true
      $0.httpAdditionalHeaders = ["User-Agent": "\(AppInfo.displayName) v\(AppInfo.version.display ?? "?"); \(Device.current.description); \(OSInfo.description)"]
      },
      delegate: nil,
      delegateQueue: nil)
  
  private var downloadingURLs: Set<URL> = []
  
  public func download(from urlString: String, downloadProgressUpdate: (@Sendable (Double) -> Void)? = nil) async throws -> Data {
    guard let url = URLComponents(string: urlString)?.url else {
      throw APIError.invalidURL
    }
    return try await download(from: url, downloadProgressUpdate: downloadProgressUpdate)
  }
  
  public func download(from url: URL, downloadProgressUpdate: (@Sendable (Double) -> Void)? = nil) async throws(HelloDownloadError) -> Data {
    guard !downloadingURLs.contains(url) else { throw .duplicate }
    downloadingURLs.insert(url)
    defer { downloadingURLs.remove(url) }
  
    let urlString = url.absoluteString.removingPercentEncoding ?? url.absoluteString
    Log.verbose(context: "Downloader", "Starting download for \(urlString)")
    
    let requestStartTime = epochTime
    
    let urlResponse: URLResponse
    let data: Data
    do {
      let dataURL: URL
      if let downloadProgressUpdate {
        (dataURL, urlResponse) = try await withCheckedThrowingContinuation { continuation in
          let task = session.downloadTask(with: URLRequest(url: url))
          task.delegate = HelloAPIDownloadTaskDelegate(continuation: continuation, progressUpdater: downloadProgressUpdate)
          task.resume()
        }
      } else {
        (dataURL, urlResponse) = try await session.download(from: url)
      }
      data = try Data(contentsOf: dataURL)
      try? FileManager.default.removeItem(at: dataURL)
    } catch {
      let nsError = error as NSError
      switch nsError.domain {
      case NSURLErrorDomain:
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet:
          Log.error(context: "Downloader", "\(String(format: "(%.2fs)", epochTime - requestStartTime)) No Network Connection - \(urlString)")
          throw .noInternet
        case NSURLErrorNetworkConnectionLost:
          Log.error(context: "Downloader", "\(String(format: "(%.2fs)", epochTime - requestStartTime)) Network Connection Lost - \(urlString)")
          throw .noInternet
        default:
          Log.error(context: "Downloader", "\(String(format: "(%.2fs)", epochTime - requestStartTime)) \(urlString) failed with url error \(nsError.code): \(error.localizedDescription)")
          throw .nsURLError(code: nsError.code)
        }
      case String(kCFErrorDomainCFNetwork):
        switch nsError.code {
        case -1100: // kCFURLErrorFileDoesNotExist:
          Log.error(context: "Downloader", "\(String(format: "(%.2fs)", epochTime - requestStartTime)) TMP Download File Not Found - \(urlString)")
          throw .noFile
        default:
          Log.error(context: "Downloader", "\(String(format: "(%.2fs)", epochTime - requestStartTime)) \(urlString) failed with cf error \(nsError.code): \(error.localizedDescription)")
          throw .cfNetworkError(code: nsError.code)
        }
      default:
        Log.error(context: "Downloader", "\(String(format: "(%.2fs)", epochTime - requestStartTime)) \(nsError.domain) \(nsError.code) \(urlString) failed with error: \(error.localizedDescription)")
        throw .other(error)
      }
    }
    let duration = String(format: "(%.2fs)", epochTime - requestStartTime)
    guard let httpResponse = urlResponse as? HTTPURLResponse else {
      Log.error(context: "Downloader", "\(duration) \(urlString) failed, no HTTP response")
      throw .noHTTPResponse
    }
    let responseStatus = HTTPResponseStatus.from(code: httpResponse.statusCode)
    guard responseStatus.isSuccess else {
      Log.error(context: "Downloader", "\(duration) \(httpResponse.statusCode) \(urlString)")
      throw .httpError(code: responseStatus)
    }
    
    Log.info(context: "Downloader", "\(duration) \(httpResponse.statusCode) \(urlString)")
    return data
  }
}
