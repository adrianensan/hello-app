import Foundation

public struct HelloDate: Codable, Equatable, Sendable {
  public var year: Int
  public var month: HelloMonth
  public var day: Int
  public var hour: Int?
  public var minute: Int?
  public var second: Int?
  
  public static var empty: HelloDate {
    HelloDate()
  }
  
  public init(
    year: Int,
    month: HelloMonth,
    day: Int,
    hour: Int? = nil,
    minute: Int? = nil,
    second: Int? = nil) {
      self.year = year
      self.month = month
      self.day = day
      self.hour = hour
      self.minute = minute
      self.second = second
  }
  
  public init(date: Date = .now) {
    self.year = Calendar.current.component(.year, from: date)
    self.month = HelloMonth(rawValue: Calendar.current.component(.month, from: .now)) ?? .january
    self.day = Calendar.current.component(.day, from: date)
    self.hour = Calendar.current.component(.hour, from: date)
    self.minute = Calendar.current.component(.minute, from: date)
    self.second = Calendar.current.component(.second, from: date)
  }
  
//  public func string(components: HelloDateComponents) -> String {
//    var string = ""
//    if components.contains(.day) {
//      string += String(day)
//    }
//    if components.contains(.month) {
//      if !string.isEmpty {
//        string += "/"
//      }
//      string += String(month.id)
//    }
//    if components.contains(.year) {
//      if !string.isEmpty {
//        string += "/"
//      }
//      string += String(year)
//    }
//    return string
//  }
  
  public func string(format: some HelloDateFormat) -> String {
    format.string(for: self)
  }
  
  public var date: Date? {
    Calendar.current.date(from: DateComponents(year: year, month: month.rawValue, day: day, hour: hour, minute: minute, second: second))
  }
}

public struct HelloDateComponents: OptionSet, Codable, Sendable {
  public static let day = HelloDateComponents(rawValue: 1 << 0)
  public static let month = HelloDateComponents(rawValue: 1 << 1)
  public static let year = HelloDateComponents(rawValue: 1 << 2)
  public static let hour = HelloDateComponents(rawValue: 1 << 3)
  public static let minute = HelloDateComponents(rawValue: 1 << 4)
  public static let second = HelloDateComponents(rawValue: 1 << 5)
  
  public static let monthAndYear: HelloDateComponents = [.month, .year]
  public static let dayMonthAndYear: HelloDateComponents = [.year, .month, .day]
  public static let dateAndFullTime: HelloDateComponents = [.year, .month, .day, .hour, .minute, .second]
  
  public let rawValue: UInt
  
  public init(rawValue: UInt) {
    self.rawValue = rawValue
  }
}
