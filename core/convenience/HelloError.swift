import Foundation

public struct HelloError: LocalizedError {
  
  public let message: String
  
  public init(_ message: String) {
    self.message = message
  }
  
  public var errorDescription: String? { message }
  
}
