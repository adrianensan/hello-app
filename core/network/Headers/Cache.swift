public enum Cache: CustomStringConvertible {
  case noCache
  case noStore
  
  private static let baseString = "HTTP/"
  
  public var description: String {
    switch self {
    case .noCache: "\(Header.cacheControl)no-cache"
    case .noStore: "\(Header.cacheControl)no-store"
    }
  }
}
