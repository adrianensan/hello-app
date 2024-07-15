import Foundation

import HelloCore

public enum AppleTVModel: CustomStringConvertible, Equatable, Sendable {

  static let identifierPrefix: String = "AppleTV"

  case tv
  case tv4K
  case tv4K2
  case tv4K3
  case unknown(modelNumber: String)

  public var description: String {
    switch self {
    case .tv: "HD"
    case .tv4K: "4K"
    case .tv4K2: "4K (2nd generation)"
    case .tv4K3: "4K (3rd generation)"
    case .unknown(let modelNumber): "[\(modelNumber)]"
    }
  }

  public static func inferFrom(modelNumber: String) -> AppleTVModel {
    switch modelNumber.deletingPrefix(AppleTVModel.identifierPrefix) {
    case "5,3": .tv
    case "6,2": .tv4K
    case "11,1": .tv4K2
    default: .unknown(modelNumber: modelNumber)
    }
  }
}
