import Foundation

public struct APIHeader {
  public var key: String
  public var value: String
  
  public static func custom(key: String, value: String) -> APIHeader {
    APIHeader(key: key, value: value)
  }
}
