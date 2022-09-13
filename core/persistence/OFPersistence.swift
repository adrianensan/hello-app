import Foundation

public class Weak<T: AnyObject> {
  public weak var value : T?
  public init (value: T) {
    self.value = value
  }
}

public actor OFPersistence<Key: PersistenceKey> {
  
  nonisolated public let defaults: UserDefaults
  nonisolated public let keychain: KeychainHelper
  
  nonisolated public let baseURL: URL
  private var allowSaving: Bool = true
  
  nonisolated public func fileURL(for subPath: String) -> URL {
    baseURL.appendingPathComponent(subPath)
  }
  
  private var updateTaskContinuations: [Key: Any] = [:]
  private var updateTasks: [Key: Any] = [:]
  private var updates: [Key: Any] = [:]
  private var cache: [Key: Any] = [:]
  
  public init(defaultsSuiteName: String?, pathRoot: URL, keychain: KeychainHelper) {
    self.defaults = UserDefaults(suiteName: defaultsSuiteName)!
    self.baseURL = pathRoot
    self.keychain = keychain
    if !FileManager.default.fileExists(atPath: baseURL.path) {
      try? FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
    }
  }
  
  private func updated<Property: PersistenceProperty>(value: Property.Value, for property: Property) where Property.Key == Key {
    if let continuation = updateTaskContinuations[property.key] as? CheckedContinuation<Property.Value, Never> {
      continuation.resume(returning: value)
      updateTasks[property.key] = nil
      updateTaskContinuations[property.key] = nil
    }
  }
  
  private func updateStream<Property: PersistenceProperty>(for property: Property) async -> Property.Value where Property.Key == Key {
    let task: Task<Property.Value, Never>
    if let stream = updateTasks[property.key] as? Task<Property.Value, Never> {
      task = stream
    } else {
      task = Task<Property.Value, Never> {
        return await withCheckedContinuation {
          updateTaskContinuations.updateValue($0, forKey: property.key)
        }
      }
      updateTasks[property.key] = task
    }
    let updatedValue = await task.value
    return updatedValue
  }
  
  public func updates<Property: PersistenceProperty>(for property: Property) -> AsyncStream<Property.Value> where Property.Key == Key {
    AsyncStream<Property.Value> { continuation in
      Task {
        while true {
          continuation.yield(await updateStream(for: property))
        }
      }
    }
  }
  
  public func save<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) where Property.Key == Key {
    guard allowSaving else { return }
    if property.isDeprecated {
      Log.warning("Using depreacted property \(property.key)", context: "Persistence")
    }
    let value = property.cleanup(value: value)
    if property.allowCache {
      cache[property.key] = value
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
        guard let data = try? JSONEncoder().encode(value) else {
          defaults.removeObject(forKey: key)
          return
        }
        defaults.set(data, forKey: key)
      }
    case .file(let path):
      let url = fileURL(for: path)
      do {
        if !FileManager.default.fileExists(atPath: url.deletingLastPathComponent().path) {
          try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        }
      } catch {
//        Log.error("Failed to create directory for \(path). Error: \(error.localizedDescription)", context: "Persistence")
      }
      
      if let string = value as? String {
        try? string.write(to: url, atomically: false, encoding: .utf8)
      } else {
        var data: Data? = value as? Data
        if data == nil {
          data = try? JSONEncoder().encode(value)
        }
        try? data?.write(to: url)
      }
    case .keychain(let key):
      if let string = value as? String? {
        if let string = string {
          keychain.set(string, for: key)
        } else {
          keychain.remove(for: key)
        }
      }
    case .memory: break
    }
    updated(value: value, for: property)
  }
  
  public nonisolated func initialValue<Property: PersistenceProperty>(for property: Property) -> Property.Value where Property.Key == Key {
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
    case .file(let path):
      let url = fileURL(for: path)
      switch Property.Value.self {
      case is String.Type, is String?.Type:
        returnValue = (try? String(contentsOf: url) as? Property.Value) ?? property.defaultValue
      default:
        guard let data = try? Data(contentsOf: url) else {
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
    case .keychain(let key):
      switch Property.Value.self {
      case is String.Type, is String?.Type:
        returnValue = keychain.string(for: key) as? Property.Value ?? property.defaultValue
      default:
        guard let data = keychain.data(for: key) else {
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
    
    let value = property.cleanup(value: returnValue)
    return value
  }
  
  public func value<Property: PersistenceProperty>(for property: Property) -> Property.Value where Property.Key == Key {
    if let rawValue = cache[property.key],
       let value = rawValue as? Property.Value {
      return value
    }
    
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
    case .file(let path):
      let url = fileURL(for: path)
      switch Property.Value.self {
      case is String.Type, is String?.Type:
        returnValue = (try? String(contentsOf: url) as? Property.Value) ?? property.defaultValue
      default:
        guard let data = try? Data(contentsOf: url) else {
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
    case .keychain(let key):
      switch Property.Value.self {
      case is String.Type, is String?.Type:
        returnValue = keychain.string(for: key) as? Property.Value ?? property.defaultValue
      default:
        guard let data = keychain.data(for: key) else {
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
    
    let value = property.cleanup(value: returnValue)
    if property.allowCache {
      cache[property.key] = value
    }
    
    return value
  }
  
  public func delete<Property: PersistenceProperty>(property: Property) where Property.Key == Key {
    cache[property.key] = nil
    
    switch property.location {
    case .defaults(let key): defaults.removeObject(forKey: key)
    case .file(let path): try? FileManager.default.removeItem(atPath: fileURL(for: path).path)
    case .keychain(let key): keychain.remove(for: key)
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
    print(defaults.dictionaryRepresentation())
    
    keychain.nuke()
    
    guard let enumerator = FileManager.default.enumerator(at: baseURL, includingPropertiesForKeys: nil) else { return }
    for file in enumerator {
      if let fileURL = file as? URL {
        try? FileManager.default.removeItem(at: fileURL)
      }
    }
  }
}

public enum Persistence {
  public static func save<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) async {
    await Property.Key.persistence.save(value, for: property)
  }
  
  public static func value<Property: PersistenceProperty>(_ property: Property) async -> Property.Value {
    await Property.Key.persistence.value(for: property)
  }
  
  public static func initialValue<Property: PersistenceProperty>(_ property: Property) -> Property.Value {
    Property.Key.persistence.initialValue(for: property)
  }
  
//  public static func initValue<Property: PersistenceProperty>(_ property: Property) -> Property.Value {
//    await Property.Key.persistence.value(for: property)
//  }
  
  public static func delete<Property: PersistenceProperty>(_ property: Property) async {
    await Property.Key.persistence.delete(property: property)
  }
  
  public static func updates<Property: PersistenceProperty>(for property: Property) async -> AsyncStream<Property.Value> {
    await Property.Key.persistence.updates(for: property)
  }
}
