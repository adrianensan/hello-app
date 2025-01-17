import Foundation

public struct Changelog: Codable, Sendable {
  
  public var version: HelloVersion
  public var notes: [ChangelogNote]
  
  public var isEmpty: Bool { notes.isEmpty }
  
  public init(from oldVersion: HelloVersion, to newVersion: HelloVersion, releases: [AppRelease]) {
    var notes: [ChangelogNote] = []
    for release in releases {
      guard release.version <= newVersion else { continue }
      guard oldVersion < release.version else { break }
      notes.append(contentsOf: release.notes)
    }
    var sortedNotes: [ChangelogNote] = []
    for type in ChangelogNoteType.allCases {
      sortedNotes.append(contentsOf: notes.filter { $0.type == type })
    }
    self.version = newVersion
    self.notes = sortedNotes.filter { $0.earliestVersionAffected ?? oldVersion <= oldVersion }
  }
}
