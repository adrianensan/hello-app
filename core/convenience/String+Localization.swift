import Foundation

public extension String {
  static func localized(_ key: String) -> String {
    String(localized: .init(stringLiteral: key))
  }
}
