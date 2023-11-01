import Foundation

public struct Point: Codable, Equatable, Hashable, Sendable {
  public var x: Double
  public var y: Double
  
  public init(x: some BinaryFloatingPoint, y: some BinaryFloatingPoint) {
    self.x = Double(x)
    self.y = Double(y)
  }
  
  public init(x: some BinaryInteger, y: some BinaryInteger) {
    self.x = Double(x)
    self.y = Double(y)
  }
  
  public var string: String {
    "(\(x), \(y))"
  }
}
