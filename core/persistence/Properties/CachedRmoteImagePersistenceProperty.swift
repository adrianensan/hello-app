import Foundation

public struct CachedRmoteImagePersistenceProperty: PersistenceProperty {
  
  public static var useAppGroup: Bool = false
  
  public let url: String
  public let variant: HelloImageVariant
  
  public var defaultValue: Data? { nil }
  
  public var location: PersistenceType {
    if Self.useAppGroup {
      .file(location: .appGroup, path: "cache/remote-images/\(variant.id)/\(url.fileSafeString)")
    } else {
      .file(location: .cache, path: "cache-images/\(variant.id)/\(url.fileSafeString)")
    }
  }
  
  public var allowCache: Bool { false }
}

public extension PersistenceProperty where Self == CachedRmoteImagePersistenceProperty {
  static func cacheRemoteIamge(url: String, variant: HelloImageVariant = .original) -> CachedRmoteImagePersistenceProperty {
    CachedRmoteImagePersistenceProperty(url: url, variant: variant)
  }
}
