import Foundation

extension Character: Codable {
  public init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    guard let character = try container.decode(String.self).first else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Decoder expected a Character but found an empty string.")
    }
    self = character
  }
  
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(String(self))
  }
}
