import Foundation

public enum AppleTVModel: CustomStringConvertible, Equatable {

  static let identifierPrefix: String = "AppleTV"

  case tv
  case tv4K
  case tv4K2
  case unknown(modelNumber: String)

  public var description: String {
    switch self {
    case .tv: "HD"
    case .tv4K: "4k"
    case .tv4K2: "4k (2nd generation)"
    case .unknown(let modelNumber): "[\(modelNumber)]"
    }
  }

  public static func inferFrom(modelNumber: String) -> AppleTVModel {
    switch modelNumber.replacingOccurrences(of: AppleTVModel.identifierPrefix, with: "") {
    case "5,3": .tv
    case "6,2": .tv4K
    case "11,1": .tv4K2
    default: .unknown(modelNumber: modelNumber)
    }
  }
}
