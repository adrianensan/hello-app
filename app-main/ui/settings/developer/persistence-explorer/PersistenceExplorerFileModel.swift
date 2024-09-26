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
  
  var bundleSnapshot: PersistenceFileSnapshotType?
  var files: PersistenceFolderSnapshot?
  var userDefaults: [UserDefaultsSnapshot] = []
  
  var sorting: PersistenceExplorerFileSorting = .alphabetical
  private(set) var deletedFiles: Set<URL> = []
  private(set) var deletedUserDefaults: Set<UserDefaultsEntry> = []
  
  init() {
    Task { try await refreshSnapshot() }
    Task {
      bundleSnapshot = try await Persistence.snapshot(of: Bundle.main.bundleURL, overrideName: "Bundle")
    }
  }
  
  func sort(userDefaultsEntries: [UserDefaultsEntry]) -> [UserDefaultsEntry] {
    userDefaultsEntries
      .filter { !deletedUserDefaults.contains($0) }
      .sorted { $0.key.sortableName < $1.key.sortableName }
  }
  
  func sort(files: [PersistenceFileSnapshotType]) -> [PersistenceFileSnapshotType] {
    switch sorting {
    case .alphabetical:
      files
        .filter { !deletedFiles.contains($0.url) }
        .sorted {
          switch ($0, $1) {
          case (.folder, .file): true
          case (.file, .folder): false
          default: $0.name.sortableName < $1.name.sortableName
          }
        }
    case .size:
      files
        .filter { !deletedFiles.contains($0.url) }
        .sorted { $0.size > $1.size }
    case .dateCreated:
      files
        .filter { !deletedFiles.contains($0.url) }
        .sorted { $0.dateCreated ?? .distantPast > $1.dateCreated ?? .distantPast }
    case .dateUpdated:
      files
        .filter { !deletedFiles.contains($0.url) }
        .sorted { $0.dateModified ?? .distantPast > $1.dateModified ?? .distantPast }
    }
  }
  
  func delete(file url: URL) {
    try? FileManager.default.removeItem(at: url)
    if !deletedFiles.contains(url) {
      deletedFiles.insert(url)
    }
  }
  
  func delete(userDefaultsObject: UserDefaultsEntry) {
    userDefaultsObject.suite.userDefaults?.removeObject(forKey: userDefaultsObject.key)
    if !deletedUserDefaults.contains(userDefaultsObject) {
      deletedUserDefaults.insert(userDefaultsObject)
    }
  }
  
  private func refreshSnapshot() async throws {
    let snapshot = try await Persistence.snapshot()
    files = snapshot.files
    userDefaults = snapshot.userDefaults
  }
}
