import Foundation

public enum AppleTVModel: CustomStringConvertible, Equatable {

  static let identifierPrefix: String = "AppleTV"

  case tv
  case tv4K
  case tv4K2
  case unknown(modelNumber: String)

  public var description: String {
    switch self {
    case .tv: return "HD"
    case .tv4K: return "4k"
    case .tv4K2: return "4k (2nd generation)"
    case .unknown(let modelNumber): return "? (\(modelNumber))"
    }
  }

  public static func inferFrom(modelNumber: String) -> AppleTVModel {
    switch modelNumber.replacingOccurrences(of: AppleTVModel.identifierPrefix, with: "") {
    case "5,3": return .tv
    case "6,2": return .tv4K
    case "11,1": return .tv4K2
    default: return .unknown(modelNumber: modelNumber)
    }
  }
}
