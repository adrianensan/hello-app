import Foundation

public struct LogsTextPersistenceProperty: PersistenceProperty {
  
  public static var persistence: HelloPersistence { Persistence.defaultPersistence }
  
  public var defaultValue: String { "" }
  
  public var location: PersistenceType { .file(location: .applicationSupport, path: "\(AppInfo.name).log") }
}

public extension PersistenceProperty where Self == LogsTextPersistenceProperty {
  static var logText: LogsTextPersistenceProperty {
    LogsTextPersistenceProperty()
  }
}
