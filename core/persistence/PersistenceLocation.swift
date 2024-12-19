import Foundation

public enum PersistenceLocationType: Sendable {
  case defaults
  case file
  case keychain
  case memory
}

public enum PersistenceType: Sendable {
  
  case defaults(suite: DefaultsPersistenceSuite = .standard, key: String)
  case file(location: FilePersistenceLocation, path: String)
  case keychain(key: String, appGroup: Bool, isBiometricallyLocked: Bool = false)
  case memory(key: String)
  
  public var id: String {
    switch self {
    case .defaults(let suite, let key): "defaults-\(suite.id)-\(key)"
    case .file(let location, let path): "file-\(location.id)-\(path)"
    case .keychain(let key, let appGroup, let isBiometricallyLocked): "keychain-\(key)\(isBiometricallyLocked ? "-bio" : "")"
    case .memory(let key): "memory-\(key)"
    }
  }
  
  public var type: PersistenceLocationType {
    switch self {
    case .defaults: .defaults
    case .file: .file
    case .keychain: .keychain
    case .memory: .memory
    }
  }
}
