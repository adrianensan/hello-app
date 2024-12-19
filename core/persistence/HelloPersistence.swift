import Foundation

public enum HelloPersistenceError: Error {
  case updatesCancelled
}

public extension UserDefaults {
  func value<Property: PersistenceProperty>(for property: Property) throws -> Property.Value {
    switch property.location {
    case .defaults(let suite, let key):
      switch Property.Value.self {
      case is Bool.Type, is Bool?.Type,
        is String.Type, is String?.Type,
        is Int.Type, is Int?.Type,
        is Double.Type, is Double?.Type,
        is Data.Type, is Data?.Type:
        if let value = suite.userDefaults?.object(forKey: key) as? Property.Value {
          return value
        } else {
          return property.defaultValue
        }
      default:
        guard let data = object(forKey: key) as? Data,
              let value = try? Property.Value.decodeJSON(from: data) else {
          return property.defaultValue
        }
        return value
      }
    default: throw HelloError("Invalid persistence type")
    }
  }
}

@HelloPersistenceActor
public class HelloPersistence: HelloPersistenceConformable {
  
  public struct Listener<Property: PersistenceProperty> {
    weak var object: AnyObject?
    var callback: @Sendable (Property.Value) async -> Void
    
    init(object: AnyObject, callback: @escaping @Sendable (Property.Value) async -> Void) {
      self.object = object
      self.callback = callback
    }
  }
  
  nonisolated public let keychain = KeychainHelper(service: AppInfo.bundleID, group: AppInfo.appGroup)
  private var allowSaving: Bool = true
  
  nonisolated public let mode: PersistenceMode = (try? UserDefaults.standard.value(for: .persistenceMode)) ?? .normal
  
  nonisolated public func fileURL(for location: FilePersistenceLocation, subPath: String, isNew: Bool) -> URL {
    baseURL(for: location, isNew: isNew).appending(component: subPath)
  }
  
  private var cache: [String: Any] = [:]
  private var listeners: [String: [Any]] = [:]
  
  nonisolated init() {}
  
  nonisolated private func userDefaults(for suite: DefaultsPersistenceSuite) -> UserDefaults {
    guard let defaults = suite.userDefaults else {
      Log.fatal(context: "Persistence", "Failed to get defaults suite for \(suite.id)")
      return .standard
    }
    return defaults
  }
  
  nonisolated private func baseURL(for location: FilePersistenceLocation, isNew: Bool) -> URL {
    guard let url = (isNew ? location.newURL : location.url) else {
      Log.fatal(context: "Persistence", "Failed to get URL for \(location.id)")
      return .temporaryDirectory
    }
    return url
  }
  
  public func listen<Property: PersistenceProperty>(for property: Property,
                                             object: AnyObject,
                                             action: @escaping @Sendable (Property.Value) async -> Void,
                                             initial: Bool = true) async {
    var propertyListeners = listeners[property.id] ?? []
    propertyListeners.append(Listener<Property>(object: object, callback: action))
    listeners[property.id] = propertyListeners
    if initial {
      await action(value(for: property))
    }
  }
  
  private func updated<Property: PersistenceProperty>(value: Property.Value, for property: Property, skipModelUpdate: Bool) {
    if !skipModelUpdate {
      Task { @MainActor in
        guard let object = Persistence.models[property.location.id]?.value else { return }
        guard let observable = object as? PersistentObservable<Property> else {
          Log.error(context: "Persistence", "Invalid type for property \(property.self), make sure 2 properties aren't sharing the same location!!!")
          return
        }
        observable._value = value
      }
    }
    
    if var listeners = listeners[property.id] as? [Listener<Property>] {
      var hasChanged = false
      for (i, listener) in listeners.enumerated().reversed() {
        if listener.object == nil {
          listeners.remove(at: i)
          hasChanged = true
        } else {
          Task { await listener.callback(value) }
        }
      }
      if hasChanged {
        self.listeners[property.id] = listeners
      }
    }
  }
  
  nonisolated public func saveInternal<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) throws {
    guard mode == .normal || property.allowedInDemoMode else { return }
    
    if property.isDeprecated {
      Log.warning(context: "Persistence", "Using depreacted property \(property.self)")
    }
    let value = property.cleanup(value: value)
    
    switch property.location {
    case .defaults(let suite, let key):
      let userDefault = userDefaults(for: suite)
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
          userDefault.removeObject(forKey: key)
          return
        }
        userDefault.set(value, forKey: key)
      default:
        let data = try value.jsonData
        userDefault.set(data, forKey: key)
      }
    case .file(let location, let path):
      try save(value, to: fileURL(for: location, subPath: path, isNew: true))
    case .keychain(let key, let appGroup, let isBiometricallyLocked):
      if let string = value as? String? {
        if let string = string {
          try keychain.set(string, for: key, appGroup: appGroup, isBiometricallyLocked: isBiometricallyLocked)
        } else {
          try? keychain.remove(for: key)
        }
      } else {
        throw HelloError("Attempted to save unsupported type in keychain")
      }
    case .memory: break
    }
  }
  
  public func save<Property: PersistenceProperty>(_ value: Property.Value, for property: Property, skipModelUpdate: Bool = false) {
    guard allowSaving else { return }
    do {
      try saveInternal(value, for: property)
      if mode != .normal && !property.allowedInDemoMode || property.allowCache {
        cache[property.id] = property.cleanup(value: value)
      }
      updated(value: value, for: property, skipModelUpdate: skipModelUpdate)
    } catch {
      Log.error(context: "Persistence", "Failed to save value for \(property.self). Error: \(error.localizedDescription)")
    }
  }
  
  public nonisolated func storedValue<Property: PersistenceProperty>(for property: Property) -> Property.Value {
    guard mode == .normal || property.allowedInDemoMode else {
      return property.defaultValue(for: mode)
    }
    let returnValue: Property.Value
    
    switch property.location {
    case .defaults(let suite, let key):
      switch Property.Value.self {
      case is Bool.Type, is Bool?.Type,
        is String.Type, is String?.Type,
        is Int.Type, is Int?.Type,
        is Double.Type, is Double?.Type,
        is Data.Type, is Data?.Type:
        if let value = userDefaults(for: suite).object(forKey: key) as? Property.Value {
          returnValue = value
        } else {
          returnValue = property.defaultValue
          if property.persistDefaultValue {
            Task { await save(returnValue, for: property) }
          }
        }
      default:
        guard let data = userDefaults(for: suite).object(forKey: key) as? Data,
              let value = try? Property.Value.decodeJSON(from: data) else {
          returnValue = property.defaultValue
          if property.persistDefaultValue {
            Task { await save(returnValue, for: property) }
          }
          break
        }
        returnValue = value
      }
    case .file(let location, let path):
      if FileManager.default.fileExists(atPath: fileURL(for: location, subPath: path, isNew: true).path) {
        returnValue = value(at: fileURL(for: location, subPath: path, isNew: true), for: property)
      } else {
        returnValue = value(at: fileURL(for: location, subPath: path, isNew: false), for: property)
      }
    case .keychain(let key, let appGroup, let isBiometricallyLocked):
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
          guard let value = try? Property.Value.decodeJSON(from: data) else {
            returnValue = property.defaultValue
            break
          }
          returnValue = value
        }
      }
    case .memory: returnValue = property.defaultValue
    }
    
    if let deprecatedProperty = property.oldProperty {
      
    }
    
    return property.cleanup(value: returnValue)
  }
  
  public func value<Property: PersistenceProperty>(for property: Property) -> Property.Value {
    if let rawValue = cache[property.id],
       let value = rawValue as? Property.Value {
      return value
    }
    
    let value = storedValue(for: property)
    if mode != .normal && !property.allowedInDemoMode || property.allowCache {
      cache[property.id] = value
    }
    
    return value
  }
  
  public func atomicUpdate<Property: PersistenceProperty>(_ property: Property, update: (Property.Value) -> Property.Value) {
    save(update(value(for: property)), for: property)
  }
  
  public func delete<Property: PersistenceProperty>(property: Property) {
    cache[property.id] = nil
    
    if mode == .normal || property.allowedInDemoMode {
      switch property.location {
      case .defaults(let suite, let key): userDefaults(for: suite).removeObject(forKey: key)
      case .file(let location, let path):
        try? FileManager.default.removeItem(atPath: fileURL(for: location, subPath: path, isNew: true).path)
        try? FileManager.default.removeItem(atPath: fileURL(for: location, subPath: path, isNew: false).path)
      case .keychain(let key, let appGroup, let isBiometricallyLocked): try? keychain.remove(for: key)
      case .memory: break
      }
    }
    updated(value: property.defaultValue, for: property, skipModelUpdate: false)
  }
  
  public func nuke() {
    guard mode == .normal else { return }
    allowSaving = false
    cache = [:]
    for suite in DefaultsPersistenceSuite.allCases {
      let userDefaults = userDefaults(for: suite)
      for key in userDefaults.dictionaryRepresentation().keys {
        userDefaults.removeObject(forKey: key)
      }
    }
    
    keychain.nuke()
    
    for location in FilePersistenceLocation.allCases {
      try? FileManager.default.removeItem(at: baseURL(for: location, isNew: true))
    }
  }
  
  nonisolated public func size<Property: PersistenceProperty>(of property: Property) -> Int {
    switch property.location {
    case .defaults: 0
    case .file(let location, let path):
      size(of: fileURL(for: location, subPath: path, isNew: true))
    case .keychain: 0
    case .memory: 0
    }
  }
  
  public func isSet<Property: PersistenceProperty>(property: Property) -> Bool {
    guard mode == .normal && property.location.type != .memory else {
      return cache[property.id] != nil
    }
    return unsafeIsSet(property: property)
  }
  
  nonisolated public func unsafeIsSet<Property: PersistenceProperty>(property: Property) -> Bool {
    guard mode == .normal else {
      if mode == .demo {
        return property.demoIsSet
      } else {
        return false
      }
    }
    return switch property.location {
    case .defaults(let suite, let key): userDefaults(for: suite).object(forKey: key) != nil
    case .file(let location, let path):
      FileManager.default.fileExists(atPath: fileURL(for: location, subPath: path, isNew: true).path) ||
      FileManager.default.fileExists(atPath: fileURL(for: location, subPath: path, isNew: false).path)
    case .keychain(let key, let appGroup, let isBiometricallyLocked): (try? keychain.data(for: key)) != nil
    case .memory: false
    }
  }
  
  nonisolated public func fileURL<Property: PersistenceProperty>(for property: Property) -> URL? {
    property.fileURL
  }
  
  nonisolated public func rootURL<Property: PersistenceProperty>(for property: Property) -> URL? {
    switch property.location {
    case .defaults: nil
    case .file(let location, let path):
      if let lastSlashIndex = path.lastIndex(of: "/") {
        fileURL(for: location, subPath: String(path[..<lastSlashIndex]), isNew: true)
      } else {
        fileURL(for: location, subPath: path, isNew: true)
      }
    case .keychain: nil
    case .memory: nil
    }
  }
  
  nonisolated private func save(_ value: some Codable & Sendable, to url: URL) throws {
    do {
      if !FileManager.default.fileExists(atPath: url.deletingLastPathComponent().path) {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
      }
    } catch {
      Log.error(context: "Persistence", "Failed to create directory at \(url.relativePath). \(error.localizedDescription)")
    }
    
    if let string = value as? String {
      try string.write(to: url, atomically: false, encoding: .utf8)
    } else {
      var data: Data? = value as? Data
      if data == nil {
        data = try value.jsonData
      }
      try data?.write(to: url)
    }
  }
  
  nonisolated private func value<Property: PersistenceProperty>(at url: URL, for property: Property) -> Property.Value {
    switch Property.Value.self {
    case is String.Type, is String?.Type:
      return (try? String(contentsOf: url, encoding: .utf8) as? Property.Value) ?? property.defaultValue
    default:
      guard let data = try? Data(contentsOf: url) else {
        return property.defaultValue
      }
      switch Property.Value.self {
      case is Data.Type, is Data?.Type:
        return (data as? Property.Value) ?? property.defaultValue
      default:
        guard let value = try? Property.Value.decodeJSON(from: data) else {
          return property.defaultValue
        }
        return value
      }
    }
  }
  
  nonisolated private func size(of url: URL) -> Int {
    url.regularFileAllocatedSize()
  }
}
