import Foundation

public struct LogStatement: Codable, Hashable, Identifiable, Sendable {
  
  public var id: String = .uuid
  public var level: LogLevel
  public var timeStamp: TimeInterval
  public var message: String
  public var context: String?
  
  public init(level: LogLevel, context: String?, message: String, timeStamp: TimeInterval = epochTime) {
    self.level = level
    self.context = context
    self.message = message
    self.timeStamp = timeStamp
  }
  
  public var timeStampString: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm:ss"
    return dateFormatter.string(from: Date(timeIntervalSince1970: timeStamp))
  }
  
  public var formattedLine: String {
    "[\(level)] \(timeStampString) \(context.flatMap { "[\($0)] " } ?? "")\(message)"
  }
}
