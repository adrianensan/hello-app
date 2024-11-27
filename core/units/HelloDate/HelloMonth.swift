import Foundation

public enum HelloMonth: Int, Codable, Identifiable, Sendable, CaseIterable {
  case january = 1
  case february
  case march
  case april
  case may
  case june
  case july
  case august
  case september
  case october
  case november
  case december
  
  public static func infer(from int: Int) -> HelloMonth? {
    HelloMonth(rawValue: int)
  }
  
  public var id: Int { rawValue }
  
  public var maxDaysInMonth: Int {
    switch self {
    case .january, .march, .may, .july, .august, .october, .december: return 31
    case .april, .june, .september, .november: return 30
    case .february: return 29
    }
  }
  
  public var shortString: String {
    switch self {
    case .january: return "Jan"
    case .february: return "Feb"
    case .march: return "Mar"
    case .april: return "Apr"
    case .may: return "May"
    case .june: return "Jun"
    case .july: return "Jul"
    case .august: return "Aug"
    case .september: return "Sep"
    case .october: return "Oct"
    case .november: return "Nov"
    case .december: return "Dec"
    }
  }
  
  public var name: String {
    switch self {
    case .january: return "january"
    case .february: return "february"
    case .march: return "march"
    case .april: return "april"
    case .may: return "may"
    case .june: return "june"
    case .july: return "july"
    case .august: return "august"
    case .september: return "september"
    case .october: return "october"
    case .november: return "november"
    case .december: return "december"
    }
  }
}
