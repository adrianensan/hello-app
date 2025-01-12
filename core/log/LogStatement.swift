import Foundation

public struct LogStatement: Codable, Hashable, Identifiable, Sendable {
  
  public var id: String = .uuid
  public var level: LogLevel
  public var timeStamp: TimeInterval
  public var message: String
  public var context: LogContext?
  public var preview: String?
  
  public init(level: LogLevel,
              context: LogContext?,
              preview: String?,
              message: String,
              timeStamp: TimeInterval = epochTime) {
    self.level = level
    self.context = context
    self.preview = preview
    self.message = message
    self.timeStamp = timeStamp
  }
  
  public var fullTimeStampString: String {
    timeStampString + "\n" + dateStampString
  }
  
  public var dateStampString: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd"
    return dateFormatter.string(from: Date(timeIntervalSince1970: timeStamp))
  }
  
  public var shortimeStampString: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm:ss"
    return dateFormatter.string(from: Date(timeIntervalSince1970: timeStamp))
  }
  
  public var timeStampString: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm:ss.SSS"
    return dateFormatter.string(from: Date(timeIntervalSince1970: timeStamp))
  }
  
  public var formattedLine: String {
    "\(timeStampString) \(level.printIcon)[\(level)] \(context.flatMap { "[\($0.string)] " } ?? "")\(message)"
  }
}
