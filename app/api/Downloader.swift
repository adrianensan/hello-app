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
        $0.httpAdditionalHeaders = ["User-Agent": "\(AppInfo.displayName) iOS v\(AppVersion.current?.display ?? "?"); \(Device.current.description); \(OSInfo.description)"]
      },
      delegate: nil,
      delegateQueue: nil
    ) +& { _session = $0 }
  }
  
  private var downloadingURLs: Set<URL> = []
  
  public func download(from urlString: String, downloadProgressUpdate: (@Sendable (Double) -> Void)? = nil) async throws -> Data {
    guard let url = URLComponents(string: urlString)?.url else {
      throw APIError.invalidURL
    }
    return try await download(from: url, downloadProgressUpdate: downloadProgressUpdate)
  }
  
  public func download(from url: URL, downloadProgressUpdate: (@MainActor @Sendable (Double) -> Void)? = nil) async throws -> Data {
    guard !downloadingURLs.contains(url) else { throw APIError.duplicate }
    downloadingURLs.insert(url)
    defer { downloadingURLs.remove(url) }
    let requestStartTime = epochTime
    var urlString = url.absoluteString.removingPercentEncoding ?? url.absoluteString
    
    let (data, urlResponse): (Data, URLResponse)
    do {
      let dataURL = try await withCheckedThrowingContinuation { continuation in
        let asyncBytes: URLSession.AsyncBytes
        let task = session.downloadTask(with: URLRequest(url: url))
        task.delegate = HelloAPIDownloadTaskDelegate(continuation: continuation, progressUpdater: downloadProgressUpdate ?? { _ in })
        task.resume()
//        (asyncBytes, urlResponse) = try await session.bytes(from: url)
//        let length = (urlResponse.expectedContentLength)
//        var dataProgress = Data()
//        dataProgress.reserveCapacity(Int(length))
//        
//        for try await byte in asyncBytes {
//          dataProgress.append(byte)
//          //        let progress = Double(dataProgress.count) / Double(length)
//          //        if dataProgress.count % 1_000_000 == 0 {
//          //          Task { @MainActor in downloadProgressUpdate?(progress) }
//          //        }
//        }
//        data = dataProgress
      }
      data = try Data(contentsOf: dataURL)
    } catch {
      let requestDuration = epochTime - requestStartTime
      Log.error("\(String(format: "(%.2fs)", requestDuration)) \(urlString) failed with error: \(error.localizedDescription)", context: "Downloader")
      throw error
    }
    let requestDuration = epochTime - requestStartTime
    let duration = String(format: "(%.2fs)", requestDuration)
    
    Log.info("\(duration) \(urlString)", context: "Downloader")
    return data
  }
}

class HelloAPIDownloadTaskDelegate: NSObject, URLSessionDownloadDelegate {
  
  var continuation: CheckedContinuation<URL, any Error>?
  let progressUpdater: (Double) -> Void
  
  init(continuation: CheckedContinuation<URL, any Error>, progressUpdater: @escaping (Double) -> Void) {
    self.continuation = continuation
    self.progressUpdater = progressUpdater
  }
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    progressUpdater(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite))
  }
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    continuation?.resume(returning: location)
    continuation = nil
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
    continuation?.resume(throwing: error ?? HelloError("Error"))
    continuation = nil
  }
  
//  public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//    progressUpdater(Double(dataTask.countOfBytesReceived) / Double(dataTask.countOfBytesExpectedToReceive))
//  }
}
