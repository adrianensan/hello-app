import Foundation

public protocol HelloDateFormat {
  func string(for date: HelloDate) -> String
  var placeHolder: String { get }
  var components: HelloDateComponents { get }
}

public struct MMYYYYDateFormat: HelloDateFormat {
  public func string(for date: HelloDate) -> String {
    "\(String(format: "%02d", date.month.rawValue))/\(date.year)"
  }
  
  public var placeHolder: String { "MM/YYYY" }
  
  public var components: HelloDateComponents { .monthAndYear }
}

public struct MMYYDateFormat: HelloDateFormat {
  public func string(for date: HelloDate) -> String {
    "\(String(format: "%02d", date.month.rawValue))/\(String(date.year).suffix(2))"
  }
  
  public var placeHolder: String { "MM/YY" }
  
  public var components: HelloDateComponents { .monthAndYear }
}

public struct YYYYMMDDDateFormat: HelloDateFormat {
  public func string(for date: HelloDate) -> String {
    "\(date.year)/\(String(format: "%02d", date.month.rawValue))/\(String(format: "%02d", date.day))"
  }
  
  public var placeHolder: String { "YYYY/MM/DD" }
  
  public var components: HelloDateComponents { .dayMonthAndYear }
}

public extension HelloDateFormat where Self == MMYYYYDateFormat {
  static var mmyyyy: MMYYYYDateFormat { MMYYYYDateFormat() }
}

public extension HelloDateFormat where Self == MMYYDateFormat {
  static var mmyy: MMYYDateFormat { MMYYDateFormat() }
}

public extension HelloDateFormat where Self == YYYYMMDDDateFormat {
  static var yyyymmdd: YYYYMMDDDateFormat { YYYYMMDDDateFormat() }
}

