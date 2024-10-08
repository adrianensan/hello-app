import Foundation

import HelloCore

public enum IPhoneModel: CustomStringConvertible, Equatable, Sendable {

  static let identifierPrefix: String = "iPhone"

  case xs, xsMax
  case xr
  case _11, _11Pro, _11ProMax
  case _12mini, _12, _12Pro, _12ProMax
  case _13mini, _13, _13Pro, _13ProMax
  case _14, _14Plus, _14Pro, _14ProMax
  case _15, _15Plus, _15Pro, _15ProMax
  case _16, _16Plus, _16Pro, _16ProMax
  case _17, _17Plus, _17Pro, _17ProMax
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
    case ._16: "16"
    case ._16Plus: "16 Plus"
    case ._16Pro: "16 Pro"
    case ._16ProMax: "16 Pro Max"
    case ._17: "17?"
    case ._17Plus: "17 Plus?"
    case ._17Pro: "17 Pro?"
    case ._17ProMax: "17 Pro Max?"
    case .se2: "SE (2020)"
    case .se3: "SE (2022)"
    case .unknown(let modelNumber): "[\(modelNumber)]"
    }
  }

  public static func inferFrom(modelNumber: String) -> IPhoneModel {
    switch modelNumber.deletingPrefix(IPhoneModel.identifierPrefix) {
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
    case "17,1": ._16Pro
    case "17,2": ._16ProMax
    case "17,3": ._16
    case "17,4": ._16Plus
    case "18,1": ._17Pro
    case "18,2": ._17ProMax
    case "18,3": ._17
    case "18,4": ._17Plus
    default: .unknown(modelNumber: modelNumber)
    }
  }
}
