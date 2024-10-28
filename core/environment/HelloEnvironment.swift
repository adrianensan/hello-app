import Foundation

/// Create a HelloEnvironmentObjectKey for each object stored in the HelloEnvironment
///
/// public struct LoggerHelloEnvironmentKey: HelloEnvironmentObjectKey {
///   public static let defaultValue: any Logger = DefaultLogger()
/// }
///
/// public extension HelloEnvironmentObjectKey where Self == LoggerHelloEnvironmentKey {
///   static var logger: LoggerHelloEnvironmentKey { LoggerHelloEnvironmentKey() }
/// }
public protocol HelloEnvironmentObjectKey<Object> {
  associatedtype Object: Sendable
  static var defaultValue: Object { get }
}

public final class HelloEnvironment: Sendable {
  
  public static let global = gloablEnvironment()
  
  private static func gloablEnvironment() -> HelloEnvironment {
    let global = HelloEnvironment(objects: globalSetupMap)
    isInitialized = true
    return global
  }
  
  private let objects: [ObjectIdentifier: any Sendable]
  
  init(objects: [ObjectIdentifier: any Sendable]) {
    self.objects = objects
  }
  
  public func object<ObjectType: HelloEnvironmentObjectKey>(for key: ObjectType) -> ObjectType.Object {
    objects[ObjectIdentifier(ObjectType.self)] as? ObjectType.Object ?? ObjectType.defaultValue
  }
  
  public static func object<ObjectType: HelloEnvironmentObjectKey>(for key: ObjectType) -> ObjectType.Object {
    global.object(for: key)
  }
  
  nonisolated(unsafe)
  private static var globalSetupMap: [ObjectIdentifier: any Sendable] = [:]
  
  nonisolated(unsafe)
  private static var isInitialized: Bool = false
  
  @MainActor
  public static func add<ObjectType: Sendable & AnyObject>(_ object: ObjectType) {
    guard !isInitialized else {
      Log.fatal(context: "Environment", "Trying to add to global environment after it's been initialized")
      return
    }
    globalSetupMap[ObjectIdentifier(ObjectType.self)] = object
  }
  
  @MainActor
  public static func add<ObjectKey: HelloEnvironmentObjectKey>(_ object: ObjectKey.Object, for key: ObjectKey) {
    guard !isInitialized else {
      Log.fatal(context: "Environment", "Trying to add to global environment after it's been initialized")
      return
    }
    globalSetupMap[ObjectIdentifier(ObjectKey.self)] = object
  }
}
