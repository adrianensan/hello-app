import Foundation

public enum IPodModel: CustomStringConvertible, Equatable {

  static let identifierPrefix: String = "iPod"

  case iPod7
  case unknown(modelNumber: String)

  public var description: String {
    switch self {
    case .iPod7: return "(7th generation)"
    case .unknown(let modelNumber): return "? (\(modelNumber))"
    }
  }

  public static func inferFrom(modelNumber: String) -> IPodModel {
    switch modelNumber.replacingOccurrences(of: IPodModel.identifierPrefix, with: "") {
    case "9,1": return .iPod7
    default: return .unknown(modelNumber: modelNumber)
    }
  }
}
