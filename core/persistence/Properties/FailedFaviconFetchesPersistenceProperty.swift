import Foundation

public struct FailedFaviconFetchesPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: [String: TimeInterval] { [:] }
  
  public var location: PersistenceType { .defaults(key: "failedFaviconFetches") }
}

public extension PersistenceProperty where Self == FailedFaviconFetchesPersistenceProperty {
  static var failedFaviconFetches: FailedFaviconFetchesPersistenceProperty {
    FailedFaviconFetchesPersistenceProperty()
  }
}
