import Foundation

import HelloCore

public actor HTTPToHTTPSRedirectServer: HTTPServer {
  
  nonisolated public var name: String { "\(host) Redirect" }
  nonisolated public let host: String
  
  init(host: String) {
    self.host = host
  }
  
  public func handle(request: HTTPRequest<Data?>) async throws -> HTTPResponse<Data?> {
    .init(status: .movedPermanently, customeHeaders: ["Location: https://\(self.host + request.url)"])
  }
}

public extension HTTPSServer {
  var httpToHttpsRedirectServer: HTTPServer {
    let host = host
    return HTTPToHTTPSRedirectServer(host: host)
  }
}
