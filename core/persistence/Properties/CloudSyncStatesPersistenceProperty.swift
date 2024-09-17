import Foundation

public struct CloudSyncState: Codable, Sendable {
  public var token: Data
  public var propertyMetadata: [String: CloudPropertyMetadata]
  
  public init(token: Data, propertyMetadata: [String: CloudPropertyMetadata] = [:]) {
    self.token = token
    self.propertyMetadata = propertyMetadata
  }
}

public struct CloudPropertyMetadata: Codable, Sendable {
  public var id: String
  public var dateModified: Date
  
  public init(id: String, dateModified: Date) {
    self.id = id
    self.dateModified = dateModified
  }
}

public struct CloudSyncStatePersistenceProperty: PersistenceProperty {
  
  public var defaultValue: CloudSyncState? { nil }
  
  public var location: PersistenceType { .file(location: .document, path: "cloud-sync-state.json") }
}

public extension PersistenceProperty where Self == CloudSyncStatePersistenceProperty {
  static var cloudSyncState: CloudSyncStatePersistenceProperty {
    CloudSyncStatePersistenceProperty()
  }
}
