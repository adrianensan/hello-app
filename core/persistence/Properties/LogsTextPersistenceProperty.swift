import Foundation

public struct LogsTextPersistenceProperty: PersistenceProperty {
  
  public static var persistence: HelloPersistence { Persistence.defaultPersistence }
  
  public var defaultValue: String { "" }
  
  public var location: PersistenceType { .supportFile(path: "\(AppInfo.name).log") }
  
  public var allowCache: Bool { false }
}

public extension PersistenceProperty where Self == LogsTextPersistenceProperty {
  static var logText: LogsTextPersistenceProperty {
    LogsTextPersistenceProperty()
  }
}
