import Foundation

public class Weak<T: AnyObject> {
  public weak var value : T?
  public init (value: T) {
    self.value = value
  }
}

public enum OFPersistenceError: Error {
  case updatesCancelled
}

extension UserDefaults: @unchecked Sendable {}

public actor OFPersistence {
  
  nonisolated public let defaults: UserDefaults
  nonisolated public let keychain: KeychainHelper
  
  nonisolated public let baseURL: URL
  private var allowSaving: Bool = true
  
  nonisolated public func fileURL(for subPath: String) -> URL {
    baseURL.appendingPathComponent(subPath)
  }
  
  private var updateTaskContinuations: [String: [String: Any]] = [:]
  private var updates: [String: Any] = [:]
  private var cache: [String: Any] = [:]
  
  public init(defaultsSuiteName: String?, pathRoot: URL, keychain: KeychainHelper) {
    self.defaults = UserDefaults(suiteName: defaultsSuiteName)!
    self.baseURL = pathRoot
    self.keychain = keychain
    if !FileManager.default.fileExists(atPath: baseURL.path) {
      try? FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
    }
  }
  
  private func updated<Property: PersistenceProperty>(value: Property.Value, for property: Property) {
    for (_, continuation) in updateTaskContinuations[property.location.id] ?? [:] {
      if let continuation = continuation as? CheckedContinuation<Property.Value, any Error> {
        continuation.resume(returning: value)
      } else {
        Log.wtf("Unexpected continuation type for \(property.self)", context: "Persistence")
      }
    }
    updateTaskContinuations[property.location.id] = nil
  }
  
//  private func updateStream<Property: PersistenceProperty>(for property: Property) async throws -> Property.Value where Property.Key == Key {
//    let task = Task<Property.Value, Error> {
//      return try await withCheckedThrowingContinuation { continuation in
//        var existingContinuations = updateTaskContinuations[property.key] ?? []
//        existingContinuations.append(continuation)
//        updateTaskContinuations.updateValue(existingContinuations, forKey: property.key)
//      }
//    }
//    var existingTasks = updateTasks[property.key] ?? []
//    existingTasks.append(task)
//    updateTasks[property.key] = existingTasks
//    let updatedValue = try await task.value
//    try Task.checkCancellation()
//    return updatedValue
//  }
  
  private func updateContinuation<Property: PersistenceProperty>(for property: Property, id: String, to newContinuation: Any?) {
    var existingContinuations = updateTaskContinuations[property.location.id] ?? [:]
    (existingContinuations[id] as? CheckedContinuation<Property.Value, any Error>)?.resume(throwing: OFPersistenceError.updatesCancelled)
    existingContinuations[id] = newContinuation
    updateTaskContinuations.updateValue(existingContinuations, forKey: property.location.id)
  }
  
  private func nextUpdate<Property: PersistenceProperty>(for property: Property, id: String) async throws -> Property.Value {
    try await withCheckedThrowingContinuation { continuation in
      updateContinuation(for: property, id: id, to: continuation)
    }
  }
  
  public func updates<Property: PersistenceProperty>(for property: Property) -> AsyncThrowingStream<Property.Value, any Error> {
    AsyncThrowingStream<Property.Value, any Error> { streamContinuation in
      let id = UUID().uuidString
      let updates = Task {
        while true {
          try Task.checkCancellation()
          let updatedValue: Property.Value = try await nextUpdate(for: property, id: id)
          try Task.checkCancellation()
          streamContinuation.yield(updatedValue)
        }
      }
      
      streamContinuation.onTermination = { _ in
        updates.cancel()
        Task { await self.updateContinuation(for: property, id: id, to: nil) }
      }
    }
  }
  
  public func save<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) {
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
          do {
            try keychain.set(string, for: key)
          } catch {
            Log.wtf("Failed to save item to keychain (Error \(error)", context: "Persistence")
          }
        } else {
          try? keychain.remove(for: key)
        }
      }
    case .memory: break
    }
    updated(value: value, for: property)
  }
  
  public nonisolated func initialValue<Property: PersistenceProperty>(for property: Property) -> Property.Value {
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
    
    let value = property.cleanup(value: returnValue)
    return value
  }
  
  public func value<Property: PersistenceProperty>(for property: Property) -> Property.Value {
    if let rawValue = cache[property.location.id],
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
    
    let value = property.cleanup(value: returnValue)
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
    case .file(let path): try? FileManager.default.removeItem(atPath: fileURL(for: path).path)
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
    case .defaults: return 0
    case .file(let path):
      guard let resourceValues = try? fileURL(for: path).resourceValues(forKeys: [
        .isRegularFileKey,
        .totalFileSizeKey,
        .fileAllocatedSizeKey,
        .totalFileAllocatedSizeKey,
      ]), resourceValues.isRegularFile == true else { return 0 }
      
      return resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0
    case .keychain: return 0
    case .memory: return 0
    }
  }
  
  public func isSet<Property: PersistenceProperty>(property: Property) -> Bool {
    switch property.location {
    case .defaults(let key): defaults.object(forKey: key) != nil
    case .file(let path): FileManager.default.fileExists(atPath: fileURL(for: path).relativePath)
    case .keychain(let key): (try? keychain.data(for: key)) != nil
    case .memory: cache[property.location.id] != nil
    }
  }
  
  nonisolated public func initialIsSet<Property: PersistenceProperty>(property: Property) -> Bool {
    switch property.location {
    case .defaults(let key): defaults.object(forKey: key) != nil
    case .file(let path): FileManager.default.fileExists(atPath: fileURL(for: path).relativePath)
    case .keychain(let key): (try? keychain.data(for: key)) != nil
    case .memory: false
    }
  }
  
  nonisolated public func fileURL<Property: PersistenceProperty>(for property: Property) -> URL? {
    switch property.location {
    case .defaults: nil
    case .file(let path): fileURL(for: path)
    case .keychain: nil
    case .memory: nil
    }
  }
  
  nonisolated public func rootURL<Property: PersistenceProperty>(for property: Property) -> URL? {
    switch property.location {
    case .defaults: nil
    case .file(let path):
      if let lastSlashIndex = path.lastIndex(of: "/") {
        fileURL(for: String(path[..<lastSlashIndex]))
      } else {
        fileURL(for: path)
      }
    case .keychain: nil
    case .memory: nil
    }
  }
}

public enum Persistence {
  
  public static var defaultPathRoot: URL {
    do {
      return try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    } catch {
      return FileManager.default.temporaryDirectory
    }
  }
  
  public static let defaultPersistence = OFPersistence(defaultsSuiteName: nil,
                                                       pathRoot: defaultPathRoot,
                                                       keychain: KeychainHelper(service: AppInfo.bundleID))
  
  public static func save<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) async {
    await Property.persistence.save(value, for: property)
  }
  
  public static func value<Property: PersistenceProperty>(_ property: Property) async -> Property.Value {
    await Property.persistence.value(for: property)
  }
  
  public static func initialValue<Property: PersistenceProperty>(_ property: Property) -> Property.Value {
    Property.persistence.initialValue(for: property)
  }
  
//  public static func initValue<Property: PersistenceProperty>(_ property: Property) -> Property.Value {
//    await Property.Key.persistence.value(for: property)
//  }
  
  public static func delete<Property: PersistenceProperty>(_ property: Property) async {
    await Property.persistence.delete(property: property)
  }
  
  public static func updates<Property: PersistenceProperty>(for property: Property) async -> AsyncThrowingStream<Property.Value, any Error> {
    await Property.persistence.updates(for: property)
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
