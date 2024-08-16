import Foundation

package enum PersistenceFileSnapshotType: Identifiable, Sendable {
  case file(PersistenceFileSnapshot)
  case folder(PersistenceFolderSnapshot)
  
  package var id: String {
    url.absoluteString
  }
  
  package var name: String {
    switch self {
    case .file(let persistenceFileSnapshot): persistenceFileSnapshot.name
    case .folder(let persistenceFolderSnapshot): persistenceFolderSnapshot.name
    }
  }
  
  package var size: DataSize {
    switch self {
    case .file(let persistenceFileSnapshot): persistenceFileSnapshot.size
    case .folder(let persistenceFolderSnapshot): persistenceFolderSnapshot.size
    }
  }
  
  package var url: URL {
    switch self {
    case .file(let persistenceFileSnapshot): persistenceFileSnapshot.url
    case .folder(let persistenceFolderSnapshot): persistenceFolderSnapshot.url
    }
  }
  
  package var dateCreated: Date? {
    switch self {
    case .file(let persistenceFileSnapshot): persistenceFileSnapshot.dateCreated
    case .folder(let persistenceFolderSnapshot): persistenceFolderSnapshot.dateCreated
    }
  }
  
  package var dateModified: Date? {
    switch self {
    case .file(let persistenceFileSnapshot): persistenceFileSnapshot.dateModified
    case .folder(let persistenceFolderSnapshot): persistenceFolderSnapshot.dateModified
    }
  }
}

package struct PersistenceFolderSnapshot: Identifiable, Sendable {
  package var name: String
  package var size: DataSize
  package var dateCreated: Date?
  package var dateModified: Date?
  package var url: URL
  package var files: [PersistenceFileSnapshotType]
  
  package var id: String { url.absoluteString }
}

package struct PersistenceFileSnapshot: Identifiable, Sendable {
  package var name: String
  package var size: DataSize
  package var dateCreated: Date?
  package var dateModified: Date?
  package var url: URL
  
  package var id: String { url.absoluteString }
}

package struct PersistenceSnapshot: Sendable {
  package var files: PersistenceFolderSnapshot
  
  init(files: PersistenceFolderSnapshot) {
    self.files = files
  }
}
