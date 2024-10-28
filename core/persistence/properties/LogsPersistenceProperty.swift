import Foundation

public struct LogsPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: [LogStatement] { [] }
  
  public var location: PersistenceType { .file(location: .applicationSupport, path: "log.json") }
}

public extension PersistenceProperty where Self == LogsPersistenceProperty {
  static var logs: LogsPersistenceProperty {
    LogsPersistenceProperty()
  }
}
