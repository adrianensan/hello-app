import Foundation

public struct DataSize: Comparable, Sendable {
  
  public var bytes: Int
  
  public init(bytes: Int) {
    self.bytes = bytes
  }
  
  public var kb: Double {
    Double(bytes) / 1000
  }
  
  public var mb: Double {
    kb / 1000
  }
  
  public var gb: Double {
    mb / 1000
  }
  
  public func string(matchingLevelOf other: DataSize? = nil) -> String {
    if gb >= 1 || (other?.gb ?? 0) >= 1 {
      return String(format: "%.2f GB", gb).replacingOccurrences(of: "0.", with: ".")
    } else if mb >= 0.1 || (other?.mb ?? 0) >= 0.1 {
      return String(format: "%.1f MB", mb)
    } else {
      return String(format: "%.1f KB", kb)
    }
  }
  
  public static func +(first: DataSize, second: DataSize) -> DataSize {
    DataSize(bytes: first.bytes + second.bytes)
  }
  
  public static func -(first: DataSize, second: DataSize) -> DataSize {
    DataSize(bytes: first.bytes - second.bytes)
  }
  
  public static func <(first: DataSize, second: DataSize) -> Bool {
    first.bytes < second.bytes
  }
}
