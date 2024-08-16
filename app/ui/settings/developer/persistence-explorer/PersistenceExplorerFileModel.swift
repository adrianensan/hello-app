import Foundation

import HelloCore

public enum PersistenceExplorerFileSorting: Sendable, CaseIterable {
  case alphabetical
  case size
  case dateCreated
  case dateUpdated
  
  public var name: String {
    switch self {
    case .alphabetical: "Alphabetical"
    case .size: "Size"
    case .dateCreated: "Date Created"
    case .dateUpdated: "Date Updated"
    }
  }
  
  public var iconName: String {
    switch self {
    case .alphabetical: "characters.uppercase"
    case .size: "internaldrive"
    case .dateCreated: "calendar"
    case .dateUpdated: "calendar.badge.clock"
    }
  }
}

@MainActor
@Observable
class PersistenceExplorerFileModel {
  
  var files: PersistenceFolderSnapshot
  
  var sorting: PersistenceExplorerFileSorting = .alphabetical
  
  init(files: PersistenceFolderSnapshot) {
    self.files = files
  }
  
  func sort(files: [PersistenceFileSnapshotType]) -> [PersistenceFileSnapshotType] {
    switch sorting {
    case .alphabetical:
      files.sorted {
        switch ($0, $1) {
        case (.folder, .file): true
        case (.file, .folder): false
        default: $0.name.lowercased() < $1.name.lowercased()
        }
      }
    case .size:
      files.sorted { $0.size > $1.size }
    case .dateCreated:
      files.sorted { $0.dateCreated ?? .distantPast > $1.dateCreated ?? .distantPast }
    case .dateUpdated:
      files.sorted { $0.dateModified ?? .distantPast > $1.dateModified ?? .distantPast }
    }
  }
}
