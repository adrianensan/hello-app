import Foundation

import HelloCore

public enum IPadModel: CustomStringConvertible, Equatable, Sendable {

  static let identifierPrefix: String = "iPad"

  case _7
  case _8
  case _9
  case _10
  
  case air3
  case air4
  case air5
  case air11Inch6
  case air13Inch6
  
  case mini5
  case mini6
  
  case pro11Inch1
  case pro11Inch2
  case pro11Inch3
  case pro11Inch4
  case pro11Inch5
  
  case pro12Inch3
  case pro12Inch4
  case pro12Inch5
  case pro12Inch6
  case pro13Inch7
  
  case unknown(modelNumber: String)

  public var description: String {
    switch self {
    case ._7: "(7th Generation)"
    case ._8: "(8th Generation)"
    case ._9: "(9th Generation)"
    case ._10: "(10th Generation)"
    case .air3: "Air (3rd Generation)"
    case .air4: "Air (4th Generation)"
    case .air5: "Air (5th Generation)"
    case .air11Inch6: "Air (11 inch) (M2)"
    case .air13Inch6: "Air (13 inch) (M2)"
    case .mini5: "mini (5th Generation)"
    case .mini6: "mini (6th Generation)"
    case .pro11Inch1: "Pro (11 inch) (1st generation)"
    case .pro11Inch2: "Pro (11 inch) (2nd generation)"
    case .pro11Inch3: "Pro (11 inch) (3rd generation)"
    case .pro11Inch4: "Pro (11 inch) (4th generation)"
    case .pro11Inch5: "Pro (11 inch) (M4)"
    case .pro12Inch3: "Pro (12.9 inch) (3rd generation)"
    case .pro12Inch4: "Pro (12.9 inch) (4th generation)"
    case .pro12Inch5: "Pro (12.9 inch) (5th generation)"
    case .pro12Inch6: "Pro (12.9 inch) (6th generation)"
    case .pro13Inch7: "Pro (13 inch) (M4)"
    case .unknown(let modelNumber): "[\(modelNumber)]"
    }
  }

  public static func inferFrom(modelNumber: String) -> IPadModel {
    switch modelNumber.deletingPrefix(IPadModel.identifierPrefix) {
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
    case "13,16", "13,17": .air5
    case "13,18", "13,19": ._10
    case "14,1": .mini6
    case "14,3", "14,4": .pro11Inch4
    case "14,5", "14,6": .pro12Inch6
    case "14,8", "14,9": .air11Inch6
    case "14,10", "14,11": .air13Inch6
    case "16,3", "16,4": .pro11Inch5
    case "16,5", "16,6": .pro13Inch7
    default: .unknown(modelNumber: modelNumber)
    }
  }
}
