import Foundation

public enum ChangelogNoteType: Codable, Equatable, CaseIterable, Sendable {
  case new
  case change
  case fix
}

public struct ChangelogNote: Codable, Equatable, Sendable {
  public var note: String
  public var type: ChangelogNoteType
  public var earliestVersionAffected: AppVersion?
  
  public static var generalBugFixes: ChangelogNote {
    ChangelogNote(note: "General Bug Fixes", type: .fix)
  }
  
  public init(note: String, type: ChangelogNoteType = .change, earliestVersionAffected: AppVersion? = nil) {
    self.note = note
    self.type = type
    self.earliestVersionAffected = earliestVersionAffected
  }
}

public struct AppRelease: Codable, Equatable, Identifiable, Sendable {
  public var version: AppVersion
  public var date: Date
  public var notes: [ChangelogNote]
  
  public var id: AppVersion { version }
  
  public init(version: AppVersion, date: Date, notes: [ChangelogNote]) {
    self.version = version
    self.date = date
    self.notes = notes
  }
}
