import Foundation

//public struct CloudSyncState: Codable, Sendable {
//  public var token: Data
//  public var propertyMetadata: [String: CloudPropertyMetadata]
//  
//  public init(token: Data, propertyMetadata: [String: CloudPropertyMetadata] = [:]) {
//    self.token = token
//    self.propertyMetadata = propertyMetadata
//  }
//}

public struct CloudPropertyMetadata: Codable, Sendable {
  public var stableID: String
  public var changeID: String
  public var dateModified: Date
  
  public init(stableID: String, changeID: String, dateModified: Date) {
    self.stableID = stableID
    self.changeID = changeID
    self.dateModified = dateModified
  }
  
  public static var new: CloudPropertyMetadata {
    CloudPropertyMetadata(stableID: .uuid, changeID: .uuid, dateModified: .distantPast)
  }
}

public struct CloudSyncStatePersistenceProperty: PersistenceProperty {
  
  public var defaultValue: [String: CloudPropertyMetadata] { [:] }
  
  public var location: PersistenceType { .file(location: .document, path: "cloud-sync-state.json") }
}

public extension PersistenceProperty where Self == CloudSyncStatePersistenceProperty {
  static var cloudSyncState: CloudSyncStatePersistenceProperty {
    CloudSyncStatePersistenceProperty()
  }
}
