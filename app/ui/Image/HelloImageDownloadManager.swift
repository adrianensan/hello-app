import Foundation

import HelloCore

public actor HelloImageDownloadManager {
  
  struct PendingDownload: Sendable {
    var url: String
    var startContinuation: CheckedContinuation<Void, any Error>
  }
  
  public static let main = HelloImageDownloadManager()
  
  let maxConcurrentDownloads: Int = 8
  
  private var pendingDownloadsStack: [PendingDownload] = []
  private var pendingDownloadsTasks: [String: Task<Data, any Error>] = [:]
  private var currentlyDownloading: Set<String> = []
  
  public func download(from url: String) async throws -> Data {
    if let existingTask = pendingDownloadsTasks[url] {
      return try await existingTask.value
    } else {
//      pendingDownloadsStack
//        .filter { $0.url == url }
//        .forEach { $0.startContinuation.resume(throwing: HelloError("Duplicate download request")) }
//      pendingDownloadsStack.removeAll { $0.url == url }
      
      let downloadTask = Task {
        try await withCheckedThrowingContinuation { continuation in
          pendingDownloadsStack.append(PendingDownload(url: url, startContinuation: continuation))
          Task { tryToStartNextDownload() }
          //      pendingDownloadsStack.insert(PendingDownload(url: url, continuation: continuation), at: 0)
        }
        do {
          let data = try await Downloader.main.download(from: url)
          Log.info("Downloaded \(url)", context: "ImageDownloader")
          return data
        } catch {
          Log.warning("Failed to download \(url)", context: "ImageDownloader")
          throw error
        }
      }
      pendingDownloadsTasks[url] = downloadTask
      return try await downloadTask.value
    }
  }
  
  private func tryToStartNextDownload() {
    guard currentlyDownloading.count < maxConcurrentDownloads,
          let nextDownload = pendingDownloadsStack.popLast()
    else { return }
    currentlyDownloading.insert(nextDownload.url)
    defer { currentlyDownloading.remove(nextDownload.url) }
    if pendingDownloadsTasks[nextDownload.url] == nil {
      Log.wtf("Pending download has no associated task!", context: "ImageDownloader")
    }
    nextDownload.startContinuation.resume()
  }
}
