import Foundation

public extension Date {
  public var relativeDateString: String {
    if Calendar.current.isDateInToday(self) {
      return "Today"
    } else if Calendar.current.isDateInYesterday(self) {
      return "Yesterday"
    } else if Date.now.timeIntervalSince1970 - timeIntervalSince1970 < 60 * 60 * 24 * 30 * 10 {
      let formatter = DateFormatter() +& { $0.dateFormat = "MMM d" }
      return formatter.string(from: self)
    } else {
      return absoluteDateString
    }
  }
  
  public var relativeDateWithGranularRecentString: String {
    let dateDiff = epochTime - self.timeIntervalSince1970
    if dateDiff < 60 {
      return "Now"
    } else if dateDiff < 60 * 60 {
      let minutes = Int(dateDiff / 60)
      return "\(minutes) minute\(minutes > 1 ? "s" : "") ago"
    } else if dateDiff < 60 * 60 * 24 {
      let hours = Int(dateDiff / 60 / 60)
      return "\(hours) hour\(hours > 1 ? "s" : "") ago"
    } else {
      return relativeDateString
    }
  }
  
  public var relativeDateWithGranularRecentShortString: String {
    let dateDiff = epochTime - self.timeIntervalSince1970
    if dateDiff < 60 {
      return "Now"
    } else if dateDiff < 60 * 60 {
      let minutes = Int(dateDiff / 60)
      return "\(minutes)m ago"
    } else if dateDiff < 60 * 60 * 24 {
      let hours = Int(dateDiff / 60 / 60)
      return "\(hours)h ago"
    } else {
      return relativeDateString
    }
  }
  
  public var absoluteDateString: String {
    let formatter = DateFormatter() +& { $0.dateFormat = "MMM d, yyyy" }
    return formatter.string(from: self)
  }
  
  public var absoluteDateAndTimeString: String {
    let formatter = DateFormatter() +& { $0.dateFormat = "hh:mm a MMM d, yyyy" }
    return formatter.string(from: self)
  }
}
