import Foundation

public struct LogsPersistenceProperty: PersistenceProperty {
  
  public static var persistence: HelloPersistence { Persistence.defaultPersistence }
  
  public var defaultValue: [LogStatement] { [] }
  
  public var location: PersistenceType { .supportFile(path: "log.json") }
  
  public var allowCache: Bool { false }
}

public extension PersistenceProperty where Self == LogsPersistenceProperty {
  static var logs: LogsPersistenceProperty {
    LogsPersistenceProperty()
  }
}
