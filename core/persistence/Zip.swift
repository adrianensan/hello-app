import Foundation

@globalActor final public actor ZipActor: GlobalActor {
  public static let shared: ZipActor = ZipActor()
}

@ZipActor
public enum Zip {
  func zip(url: URL, name: String = String.uuid) throws -> URL {
    let baseDirectoryUrl = URL.temporaryDirectory
    
    var archiveUrl: URL?
    var error: NSError?
    var innerError: Error?
    
    let coordinator = NSFileCoordinator()
    coordinator.coordinate(readingItemAt: url, options: .forUploading, error: &error) { zipUrl in
      let tmpURL: URL = .temporaryDirectory.appendingPathComponent("\(String.uuid).zip")
      do {
        try? FileManager.default.removeItem(at: tmpURL)
        try FileManager.default.moveItem(at: zipUrl, to: tmpURL)
      } catch {
        innerError = error
      }
      archiveUrl = tmpURL
    }
    if let error = innerError ?? error {
      throw error
    }
    guard let archiveUrl else {
      throw HelloError("Failed to zip")
    }
    return archiveUrl
  }
  
  func unzip() {
    #if os(macOS) || os(Linux)
    let unzipProcess = Process()
    unzipProcess.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
    unzipProcess.arguments = [zipURL.path, "-d", Self.emojiURL.path]
    try unzipProcess.run()
    unzipProcess.waitUntilExit()
    #endif
  }
}

