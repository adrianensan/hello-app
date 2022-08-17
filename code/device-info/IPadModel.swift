import Foundation

public enum IPadModel: CustomStringConvertible, Equatable {

  static let identifierPrefix: String = "iPad"

  case _5
  case _6
  case _7
  case _8
  case _9
  
  case air2
  case air3
  case air4
  
  case mini4
  case mini5
  case mini6
  
  case pro9Inch
  case pro10Inch
  case pro11Inch1
  case pro11Inch2
  case pro11Inch3
  
  case pro12Inch1
  case pro12Inch2
  case pro12Inch3
  case pro12Inch4
  case pro12Inch5
  
  case unknown(modelNumber: String)

  public var description: String {
    switch self {
    case ._5: return "(5th Generation)"
    case ._6: return "(6th Generation)"
    case ._7: return "(7th Generation)"
    case ._8: return "(8th Generation)"
    case ._9: return "(9th Generation)"
    case .air2: return "Air 2"
    case .air3: return "Air (3rd Generation)"
    case .air4: return "Air (4th Generation)"
    case .mini4: return "mini 4"
    case .mini5: return "mini (5th Generation)"
    case .mini6: return "mini (6th Generation)"
    case .pro9Inch: return "Pro (9.7 inch)"
    case .pro10Inch: return "Pro (10.5 inch)"
    case .pro11Inch1: return "Pro (11 inch) (1st generation)"
    case .pro11Inch2: return "Pro (11 inch) (2nd generation)"
    case .pro11Inch3: return "Pro (11 inch) (3rd generation)"
    case .pro12Inch1: return "Pro (12.9 inch) (1st generation)"
    case .pro12Inch2: return "Pro (12.9 inch) (2nd generation)"
    case .pro12Inch3: return "Pro (12.9 inch) (3rd generation)"
    case .pro12Inch4: return "Pro (12.9 inch) (4th generation)"
    case .pro12Inch5: return "Pro (12.9 inch) (5th generation)"
    case .unknown(let modelNumber): return "? (\(modelNumber))"
    }
  }

  public static func inferFrom(modelNumber: String) -> IPadModel {
    switch modelNumber.replacingOccurrences(of: IPadModel.identifierPrefix, with: "") {
    case "5,1", "5,2": return .mini4
    case "5,3", "5,4": return .air2
    case "6,3", "6,4": return .pro9Inch
    case "6,7", "6,8": return .pro12Inch1
    case "6,11", "6,12": return ._5
    case "7,1", "7,2": return .pro12Inch2
    case "7,3", "7,4": return .pro10Inch
    case "7,5", "7,6": return ._6
    case "7,11", "7,12": return ._7
    case "8,1", "8,2", "8,3", "8,4": return .pro11Inch1
    case "8,5", "8,6", "8,7", "8,8": return .pro12Inch3
    case "8,9", "8,10": return .pro11Inch2
    case "8,11", "8,12": return pro12Inch4
    case "11,1", "11,2": return .mini5
    case "11,4", "11,5": return .air3
    case "11,6", "11,7": return ._8
    case "13,1", "13,2": return .air4
    case "12,2": return ._9
    case "13,4", "13,5", "13,6", "13,7": return .pro11Inch3
    case "13,8", "13,9", "13,10", "13,11": return .pro12Inch5
    case "14,1": return .mini6
    default: return .unknown(modelNumber: modelNumber)
    }
  }
}
