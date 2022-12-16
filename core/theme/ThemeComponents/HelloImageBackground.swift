import Foundation

public struct HelloImageBackground: Codable {
  
  public enum Mode: Codable {
    case fill
    case fillLengthwise
    case tile
  }
  
  public var name: String
  public var mode: Mode
  
  public init(name: String, mode: Mode) {
    self.name = name
    self.mode = mode
  }
}
