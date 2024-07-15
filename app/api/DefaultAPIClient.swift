import Foundation

import HelloCore

@HelloAPIActor
public class DefaultHelloAPIClient: HelloAPIClient {
  
  public static let main = DefaultHelloAPIClient()
  
  public var session: URLSession = URLSession(
    configuration: URLSessionConfiguration.default +& {
      $0.allowsCellularAccess = true
      $0.waitsForConnectivity = false
      $0.tlsMinimumSupportedProtocolVersion = .TLSv12
      $0.tlsMaximumSupportedProtocolVersion = .TLSv13
      $0.allowsExpensiveNetworkAccess = true
      $0.allowsConstrainedNetworkAccess = true
    },
    delegate: nil,
    delegateQueue: nil)
  
  private init() {}
}

public extension HelloAPIClient where Self == DefaultHelloAPIClient {
  static var main: DefaultHelloAPIClient {
    DefaultHelloAPIClient.main
  }
}
