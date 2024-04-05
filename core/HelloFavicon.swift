import Foundation

public enum HelloFaviconType: Codable, Sendable{
  case appleTouch
  case favicon
}

public struct HelloFavicon: Codable, Sendable {
  public var data: Data
  public var type: HelloFaviconType
  
  public init(data: Data,
              type: HelloFaviconType) {
    self.data = data
    self.type = type
  }
}
