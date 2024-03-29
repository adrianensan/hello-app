import Foundation

public enum IPhoneModel: CustomStringConvertible, Equatable {

  static let identifierPrefix: String = "iPhone"

  case _6s
  case _6sPlus
  case _7
  case _7Plus
  case _8
  case _8Plus
  case x
  case xs
  case xsMax
  case xr
  case _11
  case _11Pro
  case _11ProMax
  case _12mini
  case _12
  case _12Pro
  case _12ProMax
  case _13mini
  case _13
  case _13Pro
  case _13ProMax
  case _14
  case _14Plus
  case _14Pro
  case _14ProMax
  case _15
  case _15Plus
  case _15Pro
  case _15ProMax
  case se1
  case se2
  case se3
  case unknown(modelNumber: String)

  public var description: String {
    switch self {
    case ._6s: return "6S"
    case ._6sPlus: return "6S Plus"
    case ._7: return "7"
    case ._7Plus: return "7 Plus"
    case ._8: return "8"
    case ._8Plus: return "8 Plus"
    case .x: return "X"
    case .xs: return "XS"
    case .xsMax: return "XS Max"
    case .xr: return "XR"
    case ._11: return "11"
    case ._11Pro: return "11 Pro"
    case ._11ProMax: return "11 Pro Max"
    case ._12mini: return "12 mini"
    case ._12: return "12"
    case ._12Pro: return "12 Pro"
    case ._12ProMax: return "12 Pro Max"
    case ._13mini: return "13 mini"
    case ._13: return "13"
    case ._13Pro: return "13 Pro"
    case ._13ProMax: return "13 Pro Max"
    case ._14: return "14"
    case ._14Plus: return "14 Plus"
    case ._14Pro: return "14 Pro"
    case ._14ProMax: return "14 Pro Max"
    case ._15: return "15"
    case ._15Plus: return "15 Plus"
    case ._15Pro: return "15 Pro"
    case ._15ProMax: return "15 Pro Max"
    case .se1: return "SE (2016)"
    case .se2: return "SE (2020)"
    case .se3: return "SE (2022)"
    case .unknown(let modelNumber): return "[\(modelNumber)]"
    }
  }

  public static func inferFrom(modelNumber: String) -> IPhoneModel {
    switch modelNumber.replacingOccurrences(of: IPhoneModel.identifierPrefix, with: "") {
    case "8,1": return ._6s
    case "8,2": return ._6sPlus
    case "8,4": return .se1
    case "9,1", "9,3": return ._7
    case "9,2", "9,4": return ._7Plus
    case "10,1", "10,4": return ._8
    case "10,2", "10,5": return ._8Plus
    case "10,3", "10,6": return .x
    case "11,2": return .xs
    case "11,4", "11,6": return .xsMax
    case "11,8": return .xr
    case "12,1": return ._11
    case "12,3": return ._11Pro
    case "12,5": return ._11ProMax
    case "12,8": return .se2
    case "13,1": return ._12mini
    case "13,2": return ._12
    case "13,3": return ._12Pro
    case "13,4": return ._12ProMax
    case "14,2": return ._13Pro
    case "14,3": return ._13ProMax
    case "14,4": return ._13mini
    case "14,5": return ._13
    case "14,6": return .se3
    case "14,7": return ._14
    case "14,8": return ._14Plus
    case "15,2": return ._14Pro
    case "15,3": return ._14ProMax
    case "15,4": return ._15
    case "15,5": return ._15Plus
    case "16,1": return ._15Pro
    case "16,2": return ._15ProMax
    default: return .unknown(modelNumber: modelNumber)
    }
  }
}
