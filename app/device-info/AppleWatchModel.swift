import Foundation

public enum AppleWatchModel: CustomStringConvertible, Equatable {

  static let identifierPrefix: String = "Watch"

  case series3_38mm
  case series3_42mm
  case series4_40mm
  case series4_44mm
  case series5_40mm
  case series5_44mm
  case series6_40mm
  case series6_44mm
  case seriesSE_40mm
  case seriesSE_44mm
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
    case .series3_38mm: "Series 3 - 38mm"
    case .series3_42mm: "Series 3 - 38mm"
    case .series4_40mm: "Series 4 - 40mm"
    case .series4_44mm: "Series 4 - 44mm"
    case .series5_40mm: "Series 5 - 40mm"
    case .series5_44mm: "Series 5 - 44mm"
    case .series6_40mm: "Series 6 - 40mm"
    case .series6_44mm: "Series 6 - 44mm"
    case .seriesSE_40mm: "Series SE - 40mm"
    case .seriesSE_44mm: "Series SE - 44mm"
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
    switch modelNumber.replacingOccurrences(of: AppleWatchModel.identifierPrefix, with: "") {
    case "3,1", "3,3": .series3_38mm
    case "3,2", "3,4": .series3_42mm
    case "4,1", "4,3": .series4_40mm
    case "4,2", "4,4": .series4_44mm
    case "5,1", "5,3": .series5_40mm
    case "5,2", "5,4": .series5_44mm
    case "6,1", "6,3": .series6_40mm
    case "6,2", "6,4": .series6_44mm
    case "5,9", "5,11": .seriesSE_40mm
    case "5,10", "5,12": .seriesSE_44mm
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
