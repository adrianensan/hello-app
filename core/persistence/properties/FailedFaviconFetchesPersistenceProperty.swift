import Foundation

public struct FailedImageDownloadsPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: [String: TimeInterval] { [:] }
  
  public var location: PersistenceType { .file(location: .cache, path: "failed-image-downloads.json") }
}

public extension PersistenceProperty where Self == FailedImageDownloadsPersistenceProperty {
  static var failedImageDownloads: FailedImageDownloadsPersistenceProperty {
    FailedImageDownloadsPersistenceProperty()
  }
}
