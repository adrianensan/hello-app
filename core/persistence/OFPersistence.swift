import Foundation

public class Weak<T: AnyObject> {
  public weak var value : T?
  public init (value: T) {
    self.value = value
  }
}

public enum HelloPersistenceError: Error {
  case updatesCancelled
}

extension UserDefaults: @unchecked Sendable {}

public actor HelloPersistence {
  
  nonisolated public let defaults: UserDefaults
  nonisolated public let keychain: KeychainHelper
  
  nonisolated public let baseURL: URL
  nonisolated public let applicationSupportURL: URL
  nonisolated public let temporaryURL: URL
  private var allowSaving: Bool = true
  
  nonisolated public func fileURL(for subPath: String) -> URL {
    baseURL.appending(component: subPath)
  }
  
  nonisolated public func appGroupFileURL(for subPath: String) -> URL {
    baseURL.appending(component: subPath)
  }
  
  nonisolated public func supportFileURL(for subPath: String) -> URL {
    applicationSupportURL.appending(component: subPath)
  }
  
  nonisolated public func temporaryFileURL(for subPath: String) -> URL {
    temporaryURL.appending(component: subPath)
  }
  
  private var cache: [String: Any] = [:]
  
  public init(defaultsSuiteName: String?, pathRoot: URL, keychain: KeychainHelper) {
    if let defaults = UserDefaults(suiteName: defaultsSuiteName) {
      self.defaults = defaults
    } else {
      Log.fatal("Failed to create UserDefaults for \(defaultsSuiteName), using standard instead", context: "Persistence")
      self.defaults = .standard
    }
    
    self.baseURL = pathRoot
    self.applicationSupportURL = .applicationSupportDirectory.appending(component: AppInfo.displayName, directoryHint: .isDirectory)
    self.temporaryURL = .temporaryDirectory.appending(component: AppInfo.displayName, directoryHint: .isDirectory)
    self.keychain = keychain
    if !FileManager.default.fileExists(atPath: baseURL.path) {
      try? FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
    }
    
    if !FileManager.default.fileExists(atPath: applicationSupportURL.path) {
      try? FileManager.default.createDirectory(at: applicationSupportURL, withIntermediateDirectories: true)
    }
    
    if !FileManager.default.fileExists(atPath: temporaryURL.path) {
      try? FileManager.default.createDirectory(at: temporaryURL, withIntermediateDirectories: true)
    }
  }
  
  private func updated<Property: PersistenceProperty>(value: Property.Value, for property: Property) {
    Task { @MainActor in
      if let object = Persistence.models[property.location.id]?.value {
        guard let observable = object as? PersistentObservable<Property> else {
          Log.error("Invalid type for property \(property.self), make sure 2 properties aren't sharing the same location!!!", context: "Persistence")
          return
        }
        await observable.internalValue = value
      }
    }
  }
  
  func saveInternal<Property: PersistenceProperty>(_ value: Property.Value, for property: Property, initiatedFromProperty: Bool) throws {
    guard allowSaving else { return }
    if property.isDeprecated {
      Log.warning("Using depreacted property \(property.self)", context: "Persistence")
    }
    let value = property.cleanup(value: value)
    if property.allowCache {
      cache[property.location.id] = value
    }
    
    switch property.location {
    case .defaults(let key):
      switch Property.Value.self {
      case is Bool.Type, is Bool?.Type,
        is String.Type, is String?.Type,
        is Int.Type, is Int?.Type,
        is Double.Type, is Double?.Type,
        is Data.Type, is Data?.Type:
        if let value =
            value as? Bool? ??
            value as? String? ??
            value as? Int? ??
            value as? Double? ??
            value as? Data?,
           value == nil {
          defaults.removeObject(forKey: key)
          return
        }
        defaults.set(value, forKey: key)
      default:
        let data = try value.jsonData
        defaults.set(data, forKey: key)
      }
    case .documentFile(let path):
      try save(value, to: fileURL(for: path))
    case .appGroupFile(let path):
      try save(value, to: appGroupFileURL(for: path))
    case .supportFile(let path):
      try save(value, to: supportFileURL(for: path))
    case .temporaryFile(let path):
      try save(value, to: temporaryFileURL(for: path))
    case .keychain(let key):
      if let string = value as? String? {
        if let string = string {
          try keychain.set(string, for: key)
        } else {
          try? keychain.remove(for: key)
        }
      } else {
        throw HelloError("Attempted to save unsupported type in keychain")
      }
    case .memory: break
    }
    if !initiatedFromProperty {
      updated(value: value, for: property)
    }
  }
  
  public func save<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) {
    do {
      try saveInternal(value, for: property, initiatedFromProperty: false)
    } catch {
      Log.error("Failed to save value for \(property.self). Error: \(error.localizedDescription)", context: "Persistence")
    }
  }
  
  public nonisolated func storedValue<Property: PersistenceProperty>(for property: Property) -> Property.Value {
    let returnValue: Property.Value
    
    switch property.location {
    case .defaults(let key):
      switch Property.Value.self {
      case is Bool.Type, is Bool?.Type,
        is String.Type, is String?.Type,
        is Int.Type, is Int?.Type,
        is Double.Type, is Double?.Type,
        is Data.Type, is Data?.Type:
        returnValue = defaults.object(forKey: key) as? Property.Value ?? property.defaultValue
      default:
        guard let data = defaults.object(forKey: key) as? Data,
              let value = try? JSONDecoder().decode(Property.Value.self, from: data) else {
          returnValue = property.defaultValue
          break
        }
        returnValue = value
      }
    case .documentFile(let path):
      returnValue = value(at: fileURL(for: path), for: property)
    case .appGroupFile(let path):
      returnValue = value(at: appGroupFileURL(for: path), for: property)
    case .supportFile(let path):
      returnValue = value(at: supportFileURL(for: path), for: property)
    case .temporaryFile(let path):
      returnValue = value(at: temporaryFileURL(for: path), for: property)
    case .keychain(let key):
      switch Property.Value.self {
      case is String.Type, is String?.Type:
        returnValue = (try? keychain.string(for: key) as? Property.Value) ?? property.defaultValue
      default:
        guard let data = try? keychain.data(for: key) else {
          returnValue = property.defaultValue
          break
        }
        switch Property.Value.self {
        case is Data.Type, is Data?.Type:
          returnValue = (data as? Property.Value) ?? property.defaultValue
        default:
          guard let value = try? JSONDecoder().decode(Property.Value.self, from: data) else {
            returnValue = property.defaultValue
            break
          }
          returnValue = value
        }
      }
    case .memory: returnValue = property.defaultValue
    }
    
    return property.cleanup(value: returnValue)
  }
  
  public func value<Property: PersistenceProperty>(for property: Property) -> Property.Value {
    if let rawValue = cache[property.location.id],
       let value = rawValue as? Property.Value {
      return value
    }
    
    let value = storedValue(for: property)
    if property.allowCache {
      cache[property.location.id] = value
    }
    
    return value
  }
  
  public func atomicUpdate<Property: PersistenceProperty>(_ property: Property, update: (Property.Value) -> Property.Value) {
    save(update(value(for: property)), for: property)
  }
  
  public func delete<Property: PersistenceProperty>(property: Property) {
    cache[property.location.id] = nil
    
    switch property.location {
    case .defaults(let key): defaults.removeObject(forKey: key)
    case .documentFile(let path): try? FileManager.default.removeItem(atPath: fileURL(for: path).path)
    case .appGroupFile(let path): try? FileManager.default.removeItem(atPath: appGroupFileURL(for: path).path)
    case .supportFile(let path): try? FileManager.default.removeItem(atPath: supportFileURL(for: path).path)
    case .temporaryFile(let path): try? FileManager.default.removeItem(atPath: temporaryFileURL(for: path).path)
    case .keychain(let key): try? keychain.remove(for: key)
    case .memory: break
    }
    updated(value: property.defaultValue, for: property)
  }
  
  public func nuke(stopSaving: Bool = true) {
    allowSaving = !stopSaving
    cache = [:]
    for key in defaults.dictionaryRepresentation().keys {
      defaults.removeObject(forKey: key)
    }
    
    keychain.nuke()
    
    guard let enumerator = FileManager.default.enumerator(at: baseURL, includingPropertiesForKeys: nil) else { return }
    for file in enumerator {
      if let fileURL = file as? URL {
        try? FileManager.default.removeItem(at: fileURL)
      }
    }
  }
  
  public func size<Property: PersistenceProperty>(of property: Property) -> Int {
    switch property.location {
    case .defaults: 0
    case .documentFile(let path): size(of: fileURL(for: path))
    case .appGroupFile(let path): size(of: appGroupFileURL(for: path))
    case .supportFile(let path): size(of: supportFileURL(for: path))
    case .temporaryFile(let path): size(of: temporaryFileURL(for: path))
    case .keychain: 0
    case .memory: 0
    }
  }
  
  public func isSet<Property: PersistenceProperty>(property: Property) -> Bool {
    switch property.location {
    case .defaults(let key): defaults.object(forKey: key) != nil
    case .documentFile(let path): FileManager.default.fileExists(atPath: fileURL(for: path).relativePath)
    case .appGroupFile(let path): FileManager.default.fileExists(atPath: appGroupFileURL(for: path).relativePath)
    case .supportFile(let path): FileManager.default.fileExists(atPath: supportFileURL(for: path).relativePath)
    case .temporaryFile(let path): FileManager.default.fileExists(atPath: temporaryFileURL(for: path).relativePath)
    case .keychain(let key): (try? keychain.data(for: key)) != nil
    case .memory: cache[property.location.id] != nil
    }
  }
  
  nonisolated public func initialIsSet<Property: PersistenceProperty>(property: Property) -> Bool {
    switch property.location {
    case .defaults(let key): defaults.object(forKey: key) != nil
    case .documentFile(let path): FileManager.default.fileExists(atPath: fileURL(for: path).relativePath)
    case .appGroupFile(let path): FileManager.default.fileExists(atPath: appGroupFileURL(for: path).relativePath)
    case .supportFile(let path): FileManager.default.fileExists(atPath: supportFileURL(for: path).relativePath)
    case .temporaryFile(let path): FileManager.default.fileExists(atPath: temporaryFileURL(for: path).relativePath)
    case .keychain(let key): (try? keychain.data(for: key)) != nil
    case .memory: false
    }
  }
  
  nonisolated public func fileURL<Property: PersistenceProperty>(for property: Property) -> URL? {
    switch property.location {
    case .defaults: nil
    case .documentFile(let path): fileURL(for: path)
    case .appGroupFile(let path): appGroupFileURL(for: path)
    case .supportFile(let path): supportFileURL(for: path)
    case .temporaryFile(let path): temporaryFileURL(for: path)
    case .keychain: nil
    case .memory: nil
    }
  }
  
  nonisolated public func rootURL<Property: PersistenceProperty>(for property: Property) -> URL? {
    switch property.location {
    case .defaults: nil
    case .documentFile(let path):
      if let lastSlashIndex = path.lastIndex(of: "/") {
        fileURL(for: String(path[..<lastSlashIndex]))
      } else {
        fileURL(for: path)
      }
    case .appGroupFile(let path):
      if let lastSlashIndex = path.lastIndex(of: "/") {
        appGroupFileURL(for: String(path[..<lastSlashIndex]))
      } else {
        appGroupFileURL(for: path)
      }
    case .supportFile(let path):
      if let lastSlashIndex = path.lastIndex(of: "/") {
        supportFileURL(for: String(path[..<lastSlashIndex]))
      } else {
        supportFileURL(for: path)
      }
    case .temporaryFile(let path):
      if let lastSlashIndex = path.lastIndex(of: "/") {
        temporaryFileURL(for: String(path[..<lastSlashIndex]))
      } else {
        temporaryFileURL(for: path)
      }
    case .keychain: nil
    case .memory: nil
    }
  }
  
  private func save(_ value: some Codable & Sendable, to url: URL) throws {
    do {
      if !FileManager.default.fileExists(atPath: url.deletingLastPathComponent().path) {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
      }
    } catch {
      Log.error("Failed to create directory at \(url.relativePath). \(error.localizedDescription)", context: "Persistence")
    }
    
    if let string = value as? String {
      try string.write(to: url, atomically: false, encoding: .utf8)
    } else {
      var data: Data? = value as? Data
      if data == nil {
        data = try JSONEncoder().encode(value)
      }
      try data?.write(to: url)
    }
  }
  
  nonisolated private func value<Property: PersistenceProperty>(at url: URL, for property: Property) -> Property.Value {
    switch Property.Value.self {
    case is String.Type, is String?.Type:
      return (try? String(contentsOf: url) as? Property.Value) ?? property.defaultValue
    default:
      guard let data = try? Data(contentsOf: url) else {
        return property.defaultValue
      }
      switch Property.Value.self {
      case is Data.Type, is Data?.Type:
        return (data as? Property.Value) ?? property.defaultValue
      default:
        guard let value = try? JSONDecoder().decode(Property.Value.self, from: data) else {
          return property.defaultValue
        }
        return value
      }
    }
  }
  
  
  nonisolated private func size(of url: URL) -> Int {
    guard let resourceValues = try? url.resourceValues(forKeys: [
      .isRegularFileKey,
      .totalFileSizeKey,
      .fileAllocatedSizeKey,
      .totalFileAllocatedSizeKey,
    ]), resourceValues.isRegularFile == true else { return 0 }
    
    return resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0
  }
}

public enum Persistence {
  
  fileprivate static var models: [String: Weak<AnyObject>] = [:]
  
  static func model<Property: PersistenceProperty>(for property: Property) -> PersistentObservable<Property> {
    if let weakModel = models[property.location.id],
       let model = weakModel.value as? PersistentObservable<Property> {
      return model
    } else {
      let model = PersistentObservable(property)
      models[property.location.id] = Weak(value: model)
      return model
    }
  }
  
  public static var defaultPathRoot: URL {
    do {
      return try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    } catch {
      return FileManager.default.temporaryDirectory
    }
  }
  
  public static let defaultPersistence = HelloPersistence(
    defaultsSuiteName: nil,
    pathRoot: defaultPathRoot,
    keychain: KeychainHelper(service: AppInfo.bundleID))
  
  public static func save<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) async {
    await Property.persistence.save(value, for: property)
  }
  
  public static func value<Property: PersistenceProperty>(_ property: Property) async -> Property.Value {
    await Property.persistence.value(for: property)
  }
  
  public static func initialValue<Property: PersistenceProperty>(_ property: Property) -> Property.Value {
    Property.persistence.storedValue(for: property)
  }
  
//  public static func initValue<Property: PersistenceProperty>(_ property: Property) -> Property.Value {
//    await Property.Key.persistence.value(for: property)
//  }
  
  public static func delete<Property: PersistenceProperty>(_ property: Property) async {
    await Property.persistence.delete(property: property)
  }
  
  public static func atomicUpdate<Property: PersistenceProperty>(for property: Property, update: @Sendable (Property.Value) -> Property.Value) async {
    await Property.persistence.atomicUpdate(property, update: update)
  }
  
  public static func size<Property: PersistenceProperty>(of property: Property) async -> Int {
    await Property.persistence.size(of: property)
  }
  
  public static func isSet<Property: PersistenceProperty>(property: Property) async -> Bool {
    await Property.persistence.isSet(property: property)
  }
  
  public static func initialIsSet<Property: PersistenceProperty>(property: Property) -> Bool {
    Property.persistence.initialIsSet(property: property)
  }
  
  public static func fileURL<Property: PersistenceProperty>(for property: Property) -> URL? {
    Property.persistence.fileURL(for: property)
  }
  
  public static func rootURL<Property: PersistenceProperty>(for property: Property) -> URL? {
    Property.persistence.fileURL(for: property)
  }
}
