import Foundation

public struct LogsPersistenceProperty: PersistenceProperty {
  
  public static var persistence: HelloPersistence { Persistence.defaultPersistence }
  
  public var defaultValue: [LogStatement] { [] }
  
  public var location: PersistenceType { .file(location: .applicationSupport, path: "log.json") }
}

public extension PersistenceProperty where Self == LogsPersistenceProperty {
  static var logs: LogsPersistenceProperty {
    LogsPersistenceProperty()
  }
}
