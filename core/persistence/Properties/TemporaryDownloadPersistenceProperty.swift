import Foundation

public struct TemporaryDownloadPersistenceProperty: PersistenceProperty {
  
  public let url: String
  
  public var defaultValue: Data? { nil }
  
  public var location: PersistenceType { .file(location: .temporary, path: "downloads/\(url.fileSafeString)") }
  
  public var allowCache: Bool { false }
}

public extension PersistenceProperty where Self == TemporaryDownloadPersistenceProperty {
  static func tempDownload(url: String) -> TemporaryDownloadPersistenceProperty {
    TemporaryDownloadPersistenceProperty(url: url)
  }
}