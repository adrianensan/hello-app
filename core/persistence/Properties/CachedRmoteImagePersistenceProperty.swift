import Foundation

public struct CachedRmoteImagePersistenceProperty: PersistenceProperty {
  
  public let url: String
  public let variant: HelloImageVariant
  public let useAppGroup: Bool
  
  public var defaultValue: Data? { nil }
  
  public var location: PersistenceType {
    if useAppGroup {
      .file(location: .appGroup, path: "cache/remote-images/\(variant.id)/\(url.fileSafeString)")
    } else {
      .file(location: .cache, path: "cache-images/\(variant.id)/\(url.fileSafeString)")
    }
  }
  
  public var allowCache: Bool { false }
}

public extension PersistenceProperty where Self == CachedRmoteImagePersistenceProperty {
  static func cacheRemoteIamge(url: String, variant: HelloImageVariant = .original, useAppGroup: Bool = false) -> CachedRmoteImagePersistenceProperty {
    CachedRmoteImagePersistenceProperty(url: url, variant: variant, useAppGroup: useAppGroup)
  }
}
