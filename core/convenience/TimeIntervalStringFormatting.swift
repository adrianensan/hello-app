import Foundation

public extension TimeInterval {
  var formattedDurationTrySeconds: String {
    if self < 1000 {
      return String(format: "%.2f", self)
    }
    
    let seconds = self
    let minutes = seconds / 60
    let secondsRemainder = seconds.truncatingRemainder(dividingBy: 60)
    let formattedSecondsRemainder: String
    if secondsRemainder < 10 {
      formattedSecondsRemainder = "0\(Int(secondsRemainder))"
    } else {
      formattedSecondsRemainder = "\(Int(secondsRemainder))"
    }
    
    if minutes < 60 {
      return "\(Int(minutes)):\(formattedSecondsRemainder)"
    }
    
    let hours = minutes / 60
    let minutesRemainder = minutes.truncatingRemainder(dividingBy: 60)
    let formattedMinutesRemainder: String
    if minutesRemainder < 10 {
      formattedMinutesRemainder = "0\(Int(minutesRemainder))"
    } else {
      formattedMinutesRemainder = "\(Int(minutesRemainder))"
    }
    
    return "\(Int(hours)):\(formattedMinutesRemainder):\(formattedSecondsRemainder)"
  }
  
  var formattedDuration: String {
    let seconds = self
    let minutes = seconds / 60
    let secondsRemainder = seconds.truncatingRemainder(dividingBy: 60)
    let formattedSecondsRemainder: String
    if secondsRemainder < 10 {
      formattedSecondsRemainder = "0\(Int(secondsRemainder))"
    } else {
      formattedSecondsRemainder = "\(Int(secondsRemainder))"
    }
    
    if minutes < 60 {
      return "\(Int(minutes)):\(formattedSecondsRemainder)"
    }
    
    let hours = minutes / 60
    let minutesRemainder = minutes.truncatingRemainder(dividingBy: 60)
    let formattedMinutesRemainder: String
    if minutesRemainder < 10 {
      formattedMinutesRemainder = "0\(Int(minutesRemainder))"
    } else {
      formattedMinutesRemainder = "\(Int(minutesRemainder))"
    }
    
    return "\(Int(hours)):\(formattedMinutesRemainder):\(formattedSecondsRemainder)"
  }
  
  private func s(_ count: CGFloat) -> String {
    Int(count) > 1 ? "s" : ""
  }
  
  var formattedDurationPretty: String {
    let seconds = self
    if seconds < 60 {
      return "\(Int(seconds))s"
    }
    
    let minutes = seconds / 60
    let secondsRemainder = seconds.truncatingRemainder(dividingBy: 60)
    if minutes < 60 {
      return "\(Int(minutes)) min\(s(minutes)) \(Int(secondsRemainder))s"
    }
    
    let hours = minutes / 60
    let minutesRemainder = minutes.truncatingRemainder(dividingBy: 60)
    if hours < 24 {
      return "\(Int(hours)) hr\(s(hours)) \(Int(minutesRemainder)) min\(s(minutesRemainder))"
    }
    
    let days = hours / 24
    let hoursRemainder = hours.truncatingRemainder(dividingBy: 24)
    if days < 365 {
      return "\(Int(days)) day\(s(days)) \(Int(hoursRemainder)) hr\(s(hoursRemainder))"
    }
    
    let years = days / 365
    let daysRemainder = days.truncatingRemainder(dividingBy: 365)
    return "\(Int(years)) yr\(s(years)) \(Int(daysRemainder)) day\(s(daysRemainder))"
  }
}
