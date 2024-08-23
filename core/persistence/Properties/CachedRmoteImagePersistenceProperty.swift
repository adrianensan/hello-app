import Foundation

public struct CachedRmoteImagePersistenceProperty: PersistenceProperty {
  
  public static func rootURL(for variant: HelloImageVariant) -> URL? {
    CachedRmoteImagePersistenceProperty.cacheRemoteIamge(url: "temp.heic", variant: variant).fileURL?.deletingLastPathComponent()
  }
  
  public let url: String
  public let variant: HelloImageVariant
  public let useAppGroup: Bool
  
  public var defaultValue: Data? { nil }
  
  public var location: PersistenceType {
    if useAppGroup {
      .file(location: .appGroup, path: "cache/remote-images/\(variant.id)/\(url.fileSafeString)\(variant != .original ? ".heic" : "")")
    } else {
      .file(location: .cache, path: "cache-images/\(variant.id)/\(url.fileSafeString)\(variant != .original ? ".heic" : "")")
    }
  }
  
  public var allowCache: Bool { false }
}

public extension PersistenceProperty where Self == CachedRmoteImagePersistenceProperty {
  static func cacheRemoteIamge(url: String, variant: HelloImageVariant = .original, useAppGroup: Bool = false) -> CachedRmoteImagePersistenceProperty {
    CachedRmoteImagePersistenceProperty(url: url, variant: variant, useAppGroup: useAppGroup)
  }
}
