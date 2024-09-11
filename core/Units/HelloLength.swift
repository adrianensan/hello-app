import Foundation

public struct HelloLength: Codable, Sendable, CustomStringConvertible {
  public var value: Double
  public var unit: HelloLengthUnit
  
  public var description: String {
    "\(value) \(unit)"
  }
}

public enum HelloLengthUnit: Codable, Sendable {
  case centimeters
  case inches
  
//  var 
}
