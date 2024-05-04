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
  case pro11Inch4
  
  case pro12Inch1
  case pro12Inch2
  case pro12Inch3
  case pro12Inch4
  case pro12Inch5
  case pro12Inch6
  
  case unknown(modelNumber: String)

  public var description: String {
    switch self {
    case ._5: "(5th Generation)"
    case ._6: "(6th Generation)"
    case ._7: "(7th Generation)"
    case ._8: "(8th Generation)"
    case ._9: "(9th Generation)"
    case .air2: "Air 2"
    case .air3: "Air (3rd Generation)"
    case .air4: "Air (4th Generation)"
    case .mini4: "mini 4"
    case .mini5: "mini (5th Generation)"
    case .mini6: "mini (6th Generation)"
    case .pro9Inch: "Pro (9.7 inch)"
    case .pro10Inch: "Pro (10.5 inch)"
    case .pro11Inch1: "Pro (11 inch) (1st generation)"
    case .pro11Inch2: "Pro (11 inch) (2nd generation)"
    case .pro11Inch3: "Pro (11 inch) (3rd generation)"
    case .pro11Inch4: "Pro (11 inch) (4th generation)"
    case .pro12Inch1: "Pro (12.9 inch) (1st generation)"
    case .pro12Inch2: "Pro (12.9 inch) (2nd generation)"
    case .pro12Inch3: "Pro (12.9 inch) (3rd generation)"
    case .pro12Inch4: "Pro (12.9 inch) (4th generation)"
    case .pro12Inch5: "Pro (12.9 inch) (5th generation)"
    case .pro12Inch6: "Pro (12.9 inch) (6th generation)"
    case .unknown(let modelNumber): "[\(modelNumber)]"
    }
  }

  public static func inferFrom(modelNumber: String) -> IPadModel {
    switch modelNumber.replacingOccurrences(of: IPadModel.identifierPrefix, with: "") {
    case "5,1", "5,2": .mini4
    case "5,3", "5,4": .air2
    case "6,3", "6,4": .pro9Inch
    case "6,7", "6,8": .pro12Inch1
    case "6,11", "6,12": ._5
    case "7,1", "7,2": .pro12Inch2
    case "7,3", "7,4": .pro10Inch
    case "7,5", "7,6": ._6
    case "7,11", "7,12": ._7
    case "8,1", "8,2", "8,3", "8,4": .pro11Inch1
    case "8,5", "8,6", "8,7", "8,8": .pro12Inch3
    case "8,9", "8,10": .pro11Inch2
    case "8,11", "8,12": .pro12Inch4
    case "11,1", "11,2": .mini5
    case "11,4", "11,5": .air3
    case "11,6", "11,7": ._8
    case "13,1", "13,2": .air4
    case "12,2": ._9
    case "13,4", "13,5", "13,6", "13,7": .pro11Inch3
    case "13,8", "13,9", "13,10", "13,11": .pro12Inch5
    case "14,1": .mini6
    case "14,3", "14,4": .pro11Inch4
    case "14,5", "14,6": .pro12Inch6
    default: .unknown(modelNumber: modelNumber)
    }
  }
}
