import Foundation

import HelloCore
import HelloApp

public struct TinyPNGEndpoint: APIEndpoint {
  
  public static var method: HTTPMethod { .get }
  
  public static var path: String { "/shrink" }
  
  public var host: String { "api.tinify.com" }
  
  public var headers: [APIHeader] { [
    .custom(key: "Authorization", value: "Basic Dz3RYtzdTWNsY9rPs8GPd8nDwkN0xxxy")
  ]}
  
  public var body: Data
  
  fileprivate init(imageData: Data) {
    body = imageData
  }
}

public extension APIEndpoint where Self == TinyPNGEndpoint {
  static func compressImage(imageData: Data) -> TinyPNGEndpoint {
    TinyPNGEndpoint(imageData: imageData)
  }
}
