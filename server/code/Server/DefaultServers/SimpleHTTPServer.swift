import Foundation

public actor SimpleHTTPServer: HTTPServer {
  
  nonisolated public let name: String
  nonisolated public let host: String
  nonisolated public let port: UInt16
  
  public init(name: String, host: String, port: UInt16 = 80) {
    self.name = name
    self.host = host
    self.port = port
  }
}
