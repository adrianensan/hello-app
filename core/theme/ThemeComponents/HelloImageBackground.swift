import Foundation

public struct HelloImageBackground: Codable {
  
  public enum Mode: Codable {
    case fill
    case tile
  }
  
  public var name: String
  public var mode: Mode
}
