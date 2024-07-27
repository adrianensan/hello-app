import Foundation

import HelloCore

public actor HTTPSRedirectServer: HTTPSServer {
  
  nonisolated public let targetHost: String
  nonisolated public let host: String
  nonisolated public var name: String { "\(host) Redirect" }
  public let sslFiles: SSLFiles
  public var sslContext: OpaquePointer!
  
  init(from host: String, to targetHost: String, sslFiles: SSLFiles) {
    self.targetHost = targetHost
    self.host = host
    self.sslFiles = sslFiles
  }
  
  public func handle(request: HTTPRequest<Data?>) async throws -> HTTPResponse<Data?> {
    #if DEBUG
    .init(status: .temporaryRedirect, customeHeaders: ["Location: https://\(self.targetHost + request.url)"])
    #else
    .init(status: .movedPermanently, customeHeaders: ["Location: https://\(self.targetHost + request.url)"])
    #endif
  }
}

public actor HTTPRedirectServer: HTTPServer {
  
  nonisolated public let targetHost: String
  nonisolated public let host: String
  nonisolated public var name: String { "\(host) Redirect" }
  
  init(from host: String, to targetHost: String) {
    self.targetHost = targetHost
    self.host = host
  }
  
  public func handle(request: HTTPRequest<Data?>) async throws -> HTTPResponse<Data?> {
    #if DEBUG
    .init(status: .temporaryRedirect, customeHeaders: ["Location: https://\(self.targetHost + request.url)"])
    #else
    .init(status: .movedPermanently, customeHeaders: ["Location: https://\(self.targetHost + request.url)"])
    #endif
  }
}

public extension HTTPServer {
  func redirectServer(from originHost: String, with sslFiles: SSLFiles) -> some HTTPSServer {
    let host = host
    return HTTPSRedirectServer(from: originHost, to: host, sslFiles: sslFiles)
  }
  
  func redirectServer(from originHost: String) -> some HTTPServer {
    let host = host
    return HTTPRedirectServer(from: originHost, to: host)
  }
  
  func wwwRedirectServer() -> some HTTPServer {
    let host = host
    return HTTPRedirectServer(from: "www.\(host)", to: host)
  }
  
  func wwwRedirectServer(with sslFiles: SSLFiles) -> some HTTPSServer {
    let host = host
    return HTTPSRedirectServer(from: "www.\(host)", to: host, sslFiles: sslFiles)
  }
}
