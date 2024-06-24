import Foundation

public extension Encodable {
  var jsonData: Data {
    get throws { try JSONEncoder().encode(self) }
  }
  
  var prettyJSONData: Data {
    get throws {
      let jsonEncoder = JSONEncoder()
      jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      return try jsonEncoder.encode(self)
    }
  }
}

public extension Decodable {
  static func decodeJSON(from data: Data) throws -> Self {
    try JSONDecoder().decode(Self.self, from: data)
  }
}
