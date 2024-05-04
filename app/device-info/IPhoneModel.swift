import Foundation

public enum IPhoneModel: CustomStringConvertible, Equatable {

  static let identifierPrefix: String = "iPhone"

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
  case se2
  case se3
  case unknown(modelNumber: String)

  public var description: String {
    switch self {
    case .xs: "XS"
    case .xsMax: "XS Max"
    case .xr: "XR"
    case ._11: "11"
    case ._11Pro: "11 Pro"
    case ._11ProMax: "11 Pro Max"
    case ._12mini: "12 mini"
    case ._12: "12"
    case ._12Pro: "12 Pro"
    case ._12ProMax: "12 Pro Max"
    case ._13mini: "13 mini"
    case ._13: "13"
    case ._13Pro: "13 Pro"
    case ._13ProMax: "13 Pro Max"
    case ._14: "14"
    case ._14Plus: "14 Plus"
    case ._14Pro: "14 Pro"
    case ._14ProMax: "14 Pro Max"
    case ._15: "15"
    case ._15Plus: "15 Plus"
    case ._15Pro: "15 Pro"
    case ._15ProMax: "15 Pro Max"
    case .se2: "SE (2020)"
    case .se3: "SE (2022)"
    case .unknown(let modelNumber): "[\(modelNumber)]"
    }
  }

  public static func inferFrom(modelNumber: String) -> IPhoneModel {
    switch modelNumber.replacingOccurrences(of: IPhoneModel.identifierPrefix, with: "") {
    case "11,2": .xs
    case "11,4", "11,6": .xsMax
    case "11,8": .xr
    case "12,1": ._11
    case "12,3": ._11Pro
    case "12,5": ._11ProMax
    case "12,8": .se2
    case "13,1": ._12mini
    case "13,2": ._12
    case "13,3": ._12Pro
    case "13,4": ._12ProMax
    case "14,2": ._13Pro
    case "14,3": ._13ProMax
    case "14,4": ._13mini
    case "14,5": ._13
    case "14,6": .se3
    case "14,7": ._14
    case "14,8": ._14Plus
    case "15,2": ._14Pro
    case "15,3": ._14ProMax
    case "15,4": ._15
    case "15,5": ._15Plus
    case "16,1": ._15Pro
    case "16,2": ._15ProMax
    default: .unknown(modelNumber: modelNumber)
    }
  }
}
