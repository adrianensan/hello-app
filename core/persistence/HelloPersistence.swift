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

@globalActor final public actor HelloPersistenceActor: GlobalActor {
  public static let shared: HelloPersistenceActor = HelloPersistenceActor()
}

//extension UserDefaults: @unchecked @retroactive Sendable {}

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
        if let value = object(forKey: key) as? Property.Value {
          return value
        } else {
          return property.defaultValue
        }
      default:
        guard let data = object(forKey: key) as? Data,
              let value = try? Property.Value.decodeJSON(from: data) else {
          return property.defaultValue
          break
        }
        return value
      }
    default: throw HelloError("Invalid persistence type")
    }
  }
}

@HelloPersistenceActor
public class HelloPersistence {
  
  public struct Listener<Property: PersistenceProperty> {
    weak var object: AnyObject?
    var callback: @Sendable (Property.Value) async -> Void
    
    init(object: AnyObject, callback: @escaping @Sendable (Property.Value) async -> Void) {
      self.object = object
      self.callback = callback
    }
  }
  
  nonisolated public let keychain: KeychainHelper
  private var allowSaving: Bool = true
  
  nonisolated public let mode: PersistenceMode = (try? UserDefaults.standard.value(for: .persistenceMode)) ?? .normal
  
  nonisolated public func fileURL(for location: FilePersistenceLocation, subPath: String, isNew: Bool) -> URL {
    baseURL(for: location, isNew: isNew).appending(component: subPath)
  }
  
  private var cache: [String: Any] = [:]
  private var listeners: [String: [Any]] = [:]
  private var userDefaultsCache: [DefaultsPersistenceSuite: UserDefaults] = [:]
  private var baseURLs: [FilePersistenceLocation: URL] = [:]
  
  nonisolated fileprivate init(keychain: KeychainHelper) {
    self.keychain = keychain
  }
  
  nonisolated private func userDefaults(for suite: DefaultsPersistenceSuite) -> UserDefaults {
    guard let defaults = suite.userDefaults else {
      Log.fatal("Failed to get defaults suite for \(suite.id)", context: "Persistence")
      return .standard
    }
    return defaults
//    if let userDefaults = userDefaultsCache[suite] {
//      return userDefaults
//    } else {
//      let userDefaults = suite.userDefaults ?? .standard
//      userDefaultsCache[suite] = userDefaults
//      return userDefaults
//    }
  }
  
  nonisolated private func baseURL(for location: FilePersistenceLocation, isNew: Bool) -> URL {
    guard let url = (isNew ? location.newURL : location.url) else {
      Log.error("Failed to get URL for \(location.id)", context: "Persistence")
      return .temporaryDirectory
    }
    return url
//    if let url = baseURLs[location] {
//      return url
//    } else {
//      guard let url = location.url else {
//        return .temporaryDirectory
//      }
//      baseURLs[location] = url
//      if !FileManager.default.fileExists(atPath: url.path) {
//        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
//      }
//      return url
//    }
  }
  
  func listen<Property: PersistenceProperty>(for property: Property,
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
          Log.error("Invalid type for property \(property.self), make sure 2 properties aren't sharing the same location!!!", context: "Persistence")
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
  
  nonisolated func saveInternal<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) throws {
    guard mode == .normal || property.allowedInDemoMode else { return }
    
    if property.isDeprecated {
      Log.warning("Using depreacted property \(property.self)", context: "Persistence")
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
        cache[property.location.id] = property.cleanup(value: value)
      }
      updated(value: value, for: property, skipModelUpdate: skipModelUpdate)
    } catch {
      Log.error("Failed to save value for \(property.self). Error: \(error.localizedDescription)", context: "Persistence")
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
    
    return property.cleanup(value: returnValue)
  }
  
  public func value<Property: PersistenceProperty>(for property: Property) -> Property.Value {
    if let rawValue = cache[property.location.id],
       let value = rawValue as? Property.Value {
      return value
    }
    
    let value = storedValue(for: property)
    if mode != .normal && !property.allowedInDemoMode || property.allowCache {
      cache[property.location.id] = value
    }
    
    return value
  }
  
  public func atomicUpdate<Property: PersistenceProperty>(_ property: Property, update: (Property.Value) -> Property.Value) {
    save(update(value(for: property)), for: property)
  }
  
  public func delete<Property: PersistenceProperty>(property: Property) {
    cache[property.location.id] = nil
    
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
  
  public func nuke(stopSaving: Bool = true) {
    guard mode == .normal else { return }
    allowSaving = !stopSaving
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
      return cache[property.location.id] != nil
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
      Log.error("Failed to create directory at \(url.relativePath). \(error.localizedDescription)", context: "Persistence")
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
    guard let resourceValues = try? url.resourceValues(forKeys: [
      .isRegularFileKey,
      .totalFileSizeKey,
      .fileAllocatedSizeKey,
      .totalFileAllocatedSizeKey,
    ]), resourceValues.isRegularFile == true else { return 0 }
    
    return resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0
  }
}

public enum PersistenceMode: String, Codable, Identifiable, CaseIterable, Sendable {
  case normal
  case demo
  case freshInstall
  
  public var id: String { rawValue }
  
  public var name: String {
    switch self {
    case .normal: "Normal"
    case .demo: "Demo"
    case .freshInstall: "New"
    }
  }
}

@HelloPersistenceActor
public enum Persistence {
  
  @MainActor
  fileprivate static var models: [String: Weak<AnyObject>] = [:]
  
  @MainActor
  public static func model<Property: PersistenceProperty>(for property: Property) -> PersistentObservable<Property> {
    if let weakModel = models[property.id],
       let model = weakModel.value as? PersistentObservable<Property> {
      return model
    } else {
      let model = PersistentObservable(property)
      models[property.id] = Weak(value: model)
      return model
    }
  }
  
  nonisolated public static let defaultPersistence = HelloPersistence(keychain: KeychainHelper(service: AppInfo.bundleID, group: AppInfo.appGroup))
  
  public static func save<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) {
    Property.persistence.save(value, for: property)
  }
  
  nonisolated public static func unsafeSave<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) {
    try? Property.persistence.saveInternal(value, for: property)
  }
  
  public static func value<Property: PersistenceProperty>(_ property: Property) -> Property.Value {
    Property.persistence.value(for: property)
  }
  
  nonisolated public static func unsafeValue<Property: PersistenceProperty>(_ property: Property) -> Property.Value {
    Property.persistence.storedValue(for: property)
  }
  
  @MainActor
  public static func mainActorValue<Property: PersistenceProperty>(_ property: Property) -> Property.Value {
    model(for: property).value
  }
  
  @MainActor
  public static func mainActorSave<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) {
    model(for: property).value = value
  }
  
//  public static func initValue<Property: PersistenceProperty>(_ property: Property) -> Property.Value {
//    await Property.Key.persistence.value(for: property)
//  }
  
  public static func delete<Property: PersistenceProperty>(_ property: Property) {
    Property.persistence.delete(property: property)
  }
  
  public static func listen<Property: PersistenceProperty>(for property: Property,
                                                           object: AnyObject,
                                                           initial: Bool = true,
                                                           action: @escaping @Sendable (Property.Value) async -> Void) async {
    await Property.persistence.listen(for: property, object: object, action: action, initial: initial)
  }
  
  public static func atomicUpdate<Property: PersistenceProperty>(for property: Property, update: @Sendable (consuming Property.Value) -> Property.Value) {
    Property.persistence.atomicUpdate(property, update: update)
  }
  
  nonisolated public static func size<Property: PersistenceProperty>(of property: Property) -> Int {
    Property.persistence.size(of: property)
  }
  
  public static func isSet<Property: PersistenceProperty>(property: Property) -> Bool {
    Property.persistence.isSet(property: property)
  }
  
  nonisolated public static func unsafeIsSet<Property: PersistenceProperty>(property: Property) -> Bool {
    Property.persistence.unsafeIsSet(property: property)
  }
  
  nonisolated public static func fileURL<Property: PersistenceProperty>(for property: Property) -> URL? {
    Property.persistence.fileURL(for: property)
  }
  
  nonisolated public static func rootURL<Property: PersistenceProperty>(for property: Property) -> URL? {
    Property.persistence.rootURL(for: property)
  }
  
  nonisolated public static func wipeFiles(in location: FilePersistenceLocation) throws {
    guard let url = location.newURL else { return }
    for fileURL in try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
      try FileManager.default.removeItem(at: fileURL)
    }
  }
  
  nonisolated public static func wipeFiles(in location: FilePersistenceLocation, notAccessedWithin timeInterval: TimeInterval) throws {
    guard let url = location.newURL else { return }
    try wipeFiles(in: url, notAccessedWithin: timeInterval)
  }
  
  nonisolated public static func wipeFiles(in url: URL, notAccessedWithin timeInterval: TimeInterval) throws {
    for fileURL in try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
      if fileURL.isDirectory {
        try? wipeFiles(in: fileURL, notAccessedWithin: timeInterval)
      } else if fileURL.dateAccessed ?? .distantPast < .now.addingTimeInterval(-timeInterval) {
        try? FileManager.default.removeItem(at: fileURL)
      }
    }
  }
  
  nonisolated public static func delete(location: FilePersistenceLocation) throws {
    guard let url = location.newURL else { return }
    try FileManager.default.removeItem(at: url)
  }
  
  static package func nuke() {
    for filePersistenceLocation in FilePersistenceLocation.allCases {
      if let url = filePersistenceLocation.newURL {
        try? FileManager.default.removeItem(at: url)
      }
    }
    for defaultsSuite in DefaultsPersistenceSuite.allCases {
      if let userDefaults = defaultsSuite.userDefaults {
        for key in userDefaults.dictionaryRepresentation().keys {
          userDefaults.removeObject(forKey: key)
        }
      }
    }
  }
  
  public static func snapshot(of fileURL: URL, overrideName: String? = nil) throws -> PersistenceFileSnapshotType {
    let name = fileURL.lastPathComponent
    guard FileManager.default.fileExists(atPath: fileURL.path) else { throw HelloError("No file") }
    if fileURL.isDirectory {
      var children: [PersistenceFileSnapshotType] = []
      for fileURL in try FileManager.default.contentsOfDirectory(at: fileURL, includingPropertiesForKeys: nil) {
        children.append(try snapshot(of: fileURL))
      }
      return .folder(PersistenceFolderSnapshot(
        name: overrideName ?? name,
        size: children.reduce(DataSize(bytes: 0)) { $0 + $1.size },
        sizeOnDisk: children.reduce(DataSize(bytes: 0)) { $0 + $1.sizeOnDisk },
        url: fileURL,
        files: children))
    } else {
      return .file(PersistenceFileSnapshot(
        name: name,
        size: DataSize(bytes: fileURL.fileSize()),
        sizeOnDisk: DataSize(bytes: fileURL.regularFileAllocatedSize()),
        dateCreated: fileURL.dateCreated,
        dateModified: fileURL.dateModified,
        url: fileURL))
    }
  }
  
  package static func snapshot() throws -> PersistenceSnapshot {
    var userDefaultsSnapshot: [UserDefaultsSnapshot] = []
    for defaults in DefaultsPersistenceSuite.allCases {
      if let userDefaults = defaults.userDefaults {
        userDefaultsSnapshot.append(
          UserDefaultsSnapshot(
            suite: defaults,
            objects: userDefaults.dictionaryRepresentation().map { (key, value) in
              UserDefaultsEntry(
                suite: defaults,
                key: key,
                object: UserDefaultsObjectSnapshot.infer(from: value),
                isSystem:
                  PersistenceSnapshotGenerator.systemUserDefaultKeyPrefixes.contains(where: key.starts) ||
                  PersistenceSnapshotGenerator.systemUserDefaultKeys.contains(key))
            }
          ))
      }
    }
    
    var fileSnapshots: [PersistenceFileSnapshotType] = []
    for fileLocation in FilePersistenceLocation.allCases.sorted(by: { $0.name < $1.name }) {
      if let url = fileLocation.newURL,
         let folderSnapshot = try? snapshot(of: url, overrideName: fileLocation.name) {
        fileSnapshots.append(folderSnapshot)
      }
    }
    
    return PersistenceSnapshot(userDefaults: userDefaultsSnapshot, files: PersistenceFolderSnapshot(
      name: "Root",
      size: fileSnapshots.reduce(DataSize(bytes: 0)) { $0 + $1.size },
      sizeOnDisk: fileSnapshots.reduce(DataSize(bytes: 0)) { $0 + $1.sizeOnDisk },
      url: URL(filePath: "/"),
      files: fileSnapshots))
  }
}

public extension URL {
  var isDirectory: Bool {
    (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
  }
  
  var dateCreated: Date? {
    (try? resourceValues(forKeys: [.creationDateKey]))?.creationDate
  }
  
  var dateModified: Date? {
    (try? resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
  }
  
  var dateAccessed: Date? {
    (try? resourceValues(forKeys: [.contentAccessDateKey]))?.contentAccessDate
  }
  
  func regularFileAllocatedSize() -> Int {
    guard let resourceValues = try? self.resourceValues(forKeys: [
      .isRegularFileKey,
      .totalFileSizeKey,
      .fileAllocatedSizeKey,
      .totalFileAllocatedSizeKey,
    ]),
          resourceValues.isRegularFile == true else { return 0 }
    
    return resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0
  }
  
  func fileSize() -> Int {
    guard let resourceValues = try? self.resourceValues(forKeys: [
      .isRegularFileKey,
      .totalFileSizeKey,
      .fileSizeKey,
    ]),
          resourceValues.isRegularFile == true else { return 0 }
    
    return resourceValues.totalFileSize ?? resourceValues.fileSize ?? 0
  }
}
