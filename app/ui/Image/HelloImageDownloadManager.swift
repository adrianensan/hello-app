import Foundation

import HelloCore

public actor HelloImageDownloadManager {
  
  struct PendingDownload: Sendable {
    var url: String
    var startContinuation: CheckedContinuation<Void, any Error>
  }
  
  public static let main = HelloImageDownloadManager()
  
  private let maxConcurrentDownloads: Int = 8
  
  private var pendingDownloadsStack: [PendingDownload] = []
  private var pendingDownloadsTasks: [String: Task<Data, any Error>] = [:]
  private var currentlyDownloading: Set<String> = []
  
  private var failedImageDownloads = Persistence.unsafeValue(.failedImageDownloads)
  
  private init() {
    
  }
  
  public func download(from url: String) async throws -> Data {
    if let existingTask = pendingDownloadsTasks[url] {
      return try await existingTask.value
    } else {
      if let failedFetch = failedImageDownloads[url] {
        guard epochTime - failedFetch > 60 * 60 * 24 else {
          Log.verbose("Skipping image download for \(url) due to previous failure")
          throw HelloError("Skipped")
        }
      }
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
          return try await Downloader.main.download(from: url)
        } catch HelloDownloadError.noInternet {
          throw HelloDownloadError.noInternet
        } catch {
          failedImageDownloads[url] = epochTime
          Task { await Persistence.save(failedImageDownloads, for: .failedImageDownloads) }
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
      Log.wtf(context: "ImageDownloader", "Pending download has no associated task!")
    }
    nextDownload.startContinuation.resume()
  }
}
