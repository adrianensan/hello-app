import Foundation

import HelloCore

public enum AppleWatchModel: CustomStringConvertible, Equatable, Sendable {

  static let identifierPrefix: String = "Watch"

  case series6_40mm
  case series6_44mm
  case seriesSE2_40mm
  case seriesSE2_44mm
  case series7_41mm
  case series7_45mm
  case series8_41mm
  case series8_45mm
  case ultra1
  case series9_41mm
  case series9_45mm
  case ultra2
  case unknown(modelNumber: String)

  public var description: String {
    switch self {
    case .series6_40mm: "Series 6 - 40mm"
    case .series6_44mm: "Series 6 - 44mm"
    case .seriesSE2_40mm: "Series SE 2 - 40mm"
    case .seriesSE2_44mm: "Series SE 2 - 44mm"
    case .series7_41mm: "Series 7 - 41mm"
    case .series7_45mm: "Series 7 - 45mm"
    case .series8_41mm: "Series 8 - 41mm"
    case .series8_45mm: "Series 8 - 45mm"
    case .ultra1: "Ultra 1"
    case .series9_41mm: "Series 9 - 41mm"
    case .series9_45mm: "Series 9 - 45mm"
    case .ultra2: "Ultra 2"
    case .unknown(let modelNumber): "[\(modelNumber)]"
    }
  }

  public static func inferFrom(modelNumber: String) -> AppleWatchModel {
    switch modelNumber.deletingPrefix(AppleWatchModel.identifierPrefix) {
    case "6,1", "6,3": .series6_40mm
    case "6,2", "6,4": .series6_44mm
    case "5,9", "5,11": .seriesSE2_40mm
    case "5,10", "5,12": .seriesSE2_44mm
    case "6,6", "6,8": .series7_41mm
    case "6,7", "6,9": .series7_45mm
    case "6,14", "6,16": .series8_41mm
    case "6,15", "6,17": .series8_45mm
    case "6,18": .ultra1
    case "7,1", "7.3": .series9_41mm
    case "7,2", "7.4": .series9_45mm
    case "7,5": .ultra2
    default: .unknown(modelNumber: modelNumber)
    }
  }
}
