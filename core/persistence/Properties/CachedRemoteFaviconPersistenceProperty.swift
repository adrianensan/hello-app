import Foundation

public struct CachedRemoteFaviconPersistenceProperty: PersistenceProperty {
  
  public let url: String
  public let variant: HelloImageVariant
  
  public var defaultValue: HelloFavicon? { nil }
  
  public var location: PersistenceType { .file(location: .cache, path: "cache-favicons/\(variant.id)/\(url.fileSafeString)") }
  
  public var allowCache: Bool { false }
}

public extension PersistenceProperty where Self == CachedRemoteFaviconPersistenceProperty {
  static func cacheRemoteFavicon(url: String, variant: HelloImageVariant = .original) -> CachedRemoteFaviconPersistenceProperty {
    CachedRemoteFaviconPersistenceProperty(url: url, variant: variant)
  }
}
