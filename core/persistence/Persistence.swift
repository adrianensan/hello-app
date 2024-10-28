import Foundation

@HelloPersistenceActor
public enum Persistence {
  
  @MainActor
  internal static var models: [String: Weak<AnyObject>] = [:]
  
  @MainActor
  public static func model<Property: PersistenceProperty>(for property: Property) -> PersistentObservable<Property> {
    if let weakModel = models[property.id],
       let model = weakModel.value {
      guard let model = model as? PersistentObservable<Property> else {
        Log.wtf(context: "Persistence", "Observable for \(property.id) is the wrong type, make sure property's id is unique")
        let model = PersistentObservable(property)
        models[property.id] = Weak(value: model)
        return model
      }
      return model
    } else {
      let model = PersistentObservable(property)
      models[property.id] = Weak(value: model)
      return model
    }
  }
  
  public static func save<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) {
    HelloEnvironment.object(for: .persistence).save(value, for: property)
  }
  
  nonisolated public static func unsafeSave<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) {
    try? HelloEnvironment.object(for: .persistence).saveInternal(value, for: property)
  }
  
  public static func value<Property: PersistenceProperty>(_ property: Property) -> Property.Value {
    HelloEnvironment.object(for: .persistence).value(for: property)
  }
  
  nonisolated public static func unsafeValue<Property: PersistenceProperty>(_ property: Property) -> Property.Value {
    HelloEnvironment.object(for: .persistence).storedValue(for: property)
  }
  
  @MainActor
  public static func mainActorValue<Property: PersistenceProperty>(_ property: Property) -> Property.Value {
    (models[property.id]?.value as? PersistentObservable<Property>)?.value ?? unsafeValue(property)
  }
  
  @MainActor
  public static func mainActorSave<Property: PersistenceProperty>(_ value: Property.Value, for property: Property) {
    model(for: property).value = value
  }
  
  //  public static func initValue<Property: PersistenceProperty>(_ property: Property) -> Property.Value {
  //    await Property.Key.persistence.value(for: property)
  //  }
  
  public static func delete<Property: PersistenceProperty>(_ property: Property) {
    HelloEnvironment.object(for: .persistence).delete(property: property)
  }
  
  public static func listen<Property: PersistenceProperty>(for property: Property,
                                                           object: AnyObject,
                                                           initial: Bool = true,
                                                           action: @escaping @Sendable (Property.Value) async -> Void) async {
    await HelloEnvironment.object(for: .persistence).listen(for: property, object: object, action: action, initial: initial)
  }
  
  public static func atomicUpdate<Property: PersistenceProperty>(for property: Property, update: @Sendable (consuming Property.Value) -> Property.Value) {
    HelloEnvironment.object(for: .persistence).atomicUpdate(property, update: update)
  }
  
  nonisolated public static func size<Property: PersistenceProperty>(of property: Property) -> Int {
    HelloEnvironment.object(for: .persistence).size(of: property)
  }
  
  public static func isSet<Property: PersistenceProperty>(property: Property) -> Bool {
    HelloEnvironment.object(for: .persistence).isSet(property: property)
  }
  
  nonisolated public static func unsafeIsSet<Property: PersistenceProperty>(property: Property) -> Bool {
    HelloEnvironment.object(for: .persistence).unsafeIsSet(property: property)
  }
  
  nonisolated public static func fileURL<Property: PersistenceProperty>(for property: Property) -> URL? {
    HelloEnvironment.object(for: .persistence).fileURL(for: property)
  }
  
  nonisolated public static func rootURL<Property: PersistenceProperty>(for property: Property) -> URL? {
    HelloEnvironment.object(for: .persistence).rootURL(for: property)
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
