import Foundation

public struct HelloImageBackground: Codable {
  
  public enum Mode: Codable {
    case fill
    case tile
  }
  
  var name: String
  var mode: Mode
}
