import Foundation

import HelloCore

public actor HTTPSRedirectServer: HTTPSServer {
  
  public var sslContext: OpaquePointer!
  public var sslFiles: SSLFiles
  
  public var name: String { "\(host) Redirect" }
  public var targetHost: String
  public var host: String
  
  init(from host: String, to targetHost: String, sslFiles: SSLFiles) {
    self.targetHost = targetHost
    self.host = host
    self.sslFiles = sslFiles
  }
  
  public func handle(request: HTTPRequest<Data?>) async throws -> HTTPResponse<Data?> {
    return .init(status: .movedPermanently, customeHeaders: ["Location: https://\(self.targetHost + request.url)"])
  }
}

public actor HTTPRedirectServer: HTTPServer {
  
  public var name: String { "\(host) Redirect" }
  public var targetHost: String
  public var host: String
  
  init(from host: String, to targetHost: String) {
    self.targetHost = targetHost
    self.host = host
  }
  
  public func handle(request: HTTPRequest<Data?>) async throws -> HTTPResponse<Data?> {
    return .init(status: .movedPermanently, customeHeaders: ["Location: https://\(self.targetHost + request.url)"])
  }
}

public extension HTTPServer {
  func redirectServer(from originHost: String, with sslFiles: SSLFiles) -> some HTTPSServer {
    HTTPSRedirectServer(from: originHost, to: host, sslFiles: sslFiles)
  }
  
  func redirectServer(from originHost: String) -> some HTTPServer {
    HTTPRedirectServer(from: originHost, to: host)
  }
  
  func wwwRedirectServer() -> some HTTPServer {
    HTTPRedirectServer(from: "www.\(host)", to: host)
  }
  
  func wwwRedirectServer(with sslFiles: SSLFiles) -> some HTTPSServer {
    HTTPSRedirectServer(from: "www.\(host)", to: host, sslFiles: sslFiles)
  }
}
