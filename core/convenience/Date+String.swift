import Foundation

public extension TimeInterval {
  
  static var secondsInDay: TimeInterval {
    24 * secondsInHour
  }
  
  static var secondsInHour: TimeInterval {
    60 * secondsInMinute
  }
  
  static var secondsInMinute: TimeInterval {
    60
  }
  
  var durationString: String {
    if abs(self) >= 60 * 60 {
      hhmmssString
    } else {
      mmssString
    }
  }
  
  func durationString(matchingFormatOf otherDuration: TimeInterval) -> String {
    if abs(otherDuration) >= 60 * 60 {
      hhmmssString
    } else {
      mmssString
    }
  }
  
  var hhmmssString: String {
    var durationString = self < 0 ? "-" : ""
    
    let durationMagnitude = abs(self)
    let hours: Int = Int(floor(durationMagnitude / 60 / 60))
    durationString += "\(hours):"
    
    let minutes: Int = Int(floor(durationMagnitude / 60)) % 60
    durationString += "\(String(format: "%02d", minutes)):"
    
    let seconds: Int = Int(durationMagnitude) % 60
    durationString += "\(String(format: "%02d", seconds))"
    
    return durationString
  }
  
  var mmssString: String {
    var durationString = self < 0 ? "-" : ""
    
    let durationMagnitude = abs(self)
    
    let minutes: Int = Int(floor(durationMagnitude / 60)) % 60
    if durationString.isEmpty {
      durationString = "\(minutes):"
    } else {
      durationString += "\(String(format: "%02d", minutes)):"
    }
    
    let seconds: Int = Int(durationMagnitude) % 60
    durationString += "\(String(format: "%02d", seconds))"
    
    return durationString
  }
}

public extension Date {
  var relativeDateString: String {
    if Calendar.current.isDateInToday(self) {
      return "Today"
    } else if Calendar.current.isDateInYesterday(self) {
      return "Yesterday"
    } else if Date.now.timeIntervalSince1970 - timeIntervalSince1970 > 0 && Date.now.timeIntervalSince1970 - timeIntervalSince1970 < 60 * 60 * 24 * 30 * 10 {
      let formatter = DateFormatter() +& { $0.dateFormat = "MMM d" }
      return formatter.string(from: self)
    } else {
      return absoluteDateString
    }
  }
  
  var relativeDateWithGranularRecentString: String {
    let dateDiff = epochTime - self.timeIntervalSince1970
    guard dateDiff >= 0 else { return absoluteDateString }
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
  
  var relativeDateWithGranularRecentShortString: String {
    let dateDiff = epochTime - self.timeIntervalSince1970
    guard dateDiff >= 0 else { return absoluteDateString }
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
  
  var absoluteDateString: String {
    let formatter = DateFormatter() +& { $0.dateFormat = "MMM d, yyyy" }
    return formatter.string(from: self)
  }
  
  var absoluteDateAndTimeString: String {
    let formatter = DateFormatter() +& { $0.dateFormat = "hh:mm a MMM d, yyyy" }
    return formatter.string(from: self)
  }
  
  var yearString: String {
    (DateFormatter() +& { $0.dateFormat = "yyyy" }).string(from: self)
  }
}
