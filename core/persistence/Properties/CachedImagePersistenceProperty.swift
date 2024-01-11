import Foundation

public struct CachedImagePersistenceProperty: PersistenceProperty {
  
  public let url: String
  public let variant: HelloImageVariant
  
  public var defaultValue: Data? { nil }
  
  public var location: PersistenceType { .file(location: .cache, path: "cache-images/\(variant.id)/\(url.fileSafeString)") }
  
  public var allowCache: Bool { false }
}

public extension PersistenceProperty where Self == CachedImagePersistenceProperty {
  static func cacheRemoteIamge(url: String, variant: HelloImageVariant = .original) -> CachedImagePersistenceProperty {
    CachedImagePersistenceProperty(url: url, variant: variant)
  }
}
