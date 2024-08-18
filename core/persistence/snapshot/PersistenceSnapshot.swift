import Foundation

public enum PersistenceFileSnapshotType: Identifiable, Sendable {
  case file(PersistenceFileSnapshot)
  case folder(PersistenceFolderSnapshot)
  
  public var id: String {
    url.absoluteString
  }
  
  public var name: String {
    switch self {
    case .file(let persistenceFileSnapshot): persistenceFileSnapshot.name
    case .folder(let persistenceFolderSnapshot): persistenceFolderSnapshot.name
    }
  }
  
  public var size: DataSize {
    switch self {
    case .file(let persistenceFileSnapshot): persistenceFileSnapshot.size
    case .folder(let persistenceFolderSnapshot): persistenceFolderSnapshot.size
    }
  }
  
  public var url: URL {
    switch self {
    case .file(let persistenceFileSnapshot): persistenceFileSnapshot.url
    case .folder(let persistenceFolderSnapshot): persistenceFolderSnapshot.url
    }
  }
  
  public var dateCreated: Date? {
    switch self {
    case .file(let persistenceFileSnapshot): persistenceFileSnapshot.dateCreated
    case .folder(let persistenceFolderSnapshot): persistenceFolderSnapshot.dateCreated
    }
  }
  
  public var dateModified: Date? {
    switch self {
    case .file(let persistenceFileSnapshot): persistenceFileSnapshot.dateModified
    case .folder(let persistenceFolderSnapshot): persistenceFolderSnapshot.dateModified
    }
  }
}

public enum UserDefaultsObjectSnapshot: Hashable, Sendable {
  case string(String)
  case boolean(Bool)
  case int(Int)
  case double(Double)
  case data(Data)
  case stringArray([String])
  case unknown
  
  public var iconName: String {
    switch self {
    case .string: "textformat.size.smaller"
    case .boolean: "switch.2"
    case .int: "number"
    case .double: "number"
    case .data: "externaldrive"
    case .stringArray: "externaldrive"
    case .unknown: "questionmark.app"
    }
  }
  
  public var previewString: String {
    switch self {
    case .string(let string): string.count < 6 ? #""\#(string)""# : "String(\(string.count))"
    case .boolean(let bool): "\(bool ? "TRUE" : "FALSE")"
    case .int(let int): "\(int)"
    case .double(let double): String(format: "%.2f", double)
    case .data(let data): "\(DataSize(bytes: data.count).string())"
    case .stringArray(let stringArray): "[String](\(stringArray.count))"
    case .unknown: "Unknown"
    }
  }
  
  public var string: String {
    switch self {
    case .string(let string): string
    case .boolean(let bool): previewString
    case .int(let int): previewString
    case .double(let double): previewString
    case .data(let data): previewString
    case .stringArray(let stringArray): previewString
    case .unknown: previewString
    }
  }
  
  public static func infer(from object: Any) -> UserDefaultsObjectSnapshot {
    if let stringArray = object as? [String] {
      .stringArray(stringArray)
    } else if let bool = object as? Bool {
      .boolean(bool)
    } else if let int = object as? Int {
      .int(int)
    } else if let double = object as? Double {
      .double(double)
    } else if let string = object as? String {
      .string(string)
    } else if let data = object as? Data {
      .data(data)
    } else {
      .unknown
    }
  }
}

public struct UserDefaultsEntry: Identifiable, Hashable, Sendable {
  public var suite: DefaultsPersistenceSuite
  public var key: String
  public var object: UserDefaultsObjectSnapshot
  public var isSystem: Bool
  
  public var id: String { key }
}

public struct UserDefaultsSnapshot: Identifiable, Sendable {
  public var suite: DefaultsPersistenceSuite
  public var objects: [UserDefaultsEntry]
  
  public var id: String { suite.id }
}

public struct PersistenceFolderSnapshot: Identifiable, Sendable {
  package var name: String
  package var size: DataSize
  package var dateCreated: Date?
  package var dateModified: Date?
  package var url: URL
  package var files: [PersistenceFileSnapshotType]
  
  public var id: String { url.absoluteString }
}

public struct PersistenceFileSnapshot: Identifiable, Sendable {
  package var name: String
  package var size: DataSize
  package var dateCreated: Date?
  package var dateModified: Date?
  package var url: URL
  
  public var id: String { url.absoluteString }
}

public struct PersistenceSnapshot: Sendable {
  package var files: PersistenceFolderSnapshot
  package var userDefaults: [UserDefaultsSnapshot]
  
  init(userDefaults: [UserDefaultsSnapshot], files: PersistenceFolderSnapshot) {
    self.userDefaults = userDefaults
    self.files = files
  }
}
