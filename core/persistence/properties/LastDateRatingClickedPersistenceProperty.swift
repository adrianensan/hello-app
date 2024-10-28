import Foundation

public struct LastDateRatingClickedPersistenceProperty: PersistenceProperty {
  
  public var defaultValue: Date { .distantPast }
  
  public var location: PersistenceType { .defaults(key: "last-date-rating-clicked") }
}

public extension PersistenceProperty where Self == LastDateRatingClickedPersistenceProperty {
  static var lastDateRatingClicked: LastDateRatingClickedPersistenceProperty {
    LastDateRatingClickedPersistenceProperty()
  }
}
