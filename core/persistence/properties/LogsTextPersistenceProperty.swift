import Foundation

public struct LogsTextPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: String { "" }
  
  public var location: PersistenceType { .file(location: .applicationSupport, path: "\(AppInfo.name)-log.txt") }
}

public extension PersistenceProperty where Self == LogsTextPersistenceProperty {
  static var logText: LogsTextPersistenceProperty {
    LogsTextPersistenceProperty()
  }
}
