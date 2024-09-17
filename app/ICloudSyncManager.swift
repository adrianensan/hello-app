import Foundation
import CloudKit

import HelloCore

public enum ICloudState: Sendable {
  case ok
  case authenticationError
  case accountMismatch
  case notDetermined
  case notSignedIn
  case networkError
  case dbError
  case genericError
}

@MainActor
@Observable
public class ICloudStateModel {
  
  public static let main = ICloudStateModel()
  
  public var state: ICloudState = .notDetermined
}

public enum ICloudPropertyValueType: Sendable {
  case data
  case asset
}

public enum ICloudPropertyScope: Sendable {
  case app
  case hello
}

public protocol ICloudProperty: Sendable {
  
  associatedtype Value: Codable & Sendable
  
  var recordID: String { get }
  
  /// ONLY letters
  var recordType: String { get }
  var valueType: ICloudPropertyValueType { get }
  var scope: ICloudPropertyScope { get }
}

public actor ICloudSyncManager {
  
  public static let main = ICloudSyncManager()
  
  private let appDatabase = CKContainer(identifier: AppInfo.iCloudContainer).privateCloudDatabase
  private let helloDatabase = CKContainer(identifier: AppInfo.sharedHelloICloudContainer).privateCloudDatabase
  
  public private(set) var state: ICloudState = .notDetermined {
    didSet {
      let state = state
      Task { @MainActor in
        ICloudStateModel.main.state = state
      }
    }
  }
  
  private let assetKey = "data"
  
  private var isSyncing: Bool = false
  private var awatingSync: Bool = false
  
//  public static func setupSubscription() async {
//    
//    let subscription = CKQuerySubscription(
//      recordType: recordType,
//      predicate: NSPredicate(value: true),
//      subscriptionID: subscriptionID)
//    subscription.notificationInfo = CKSubscription.NotificationInfo(shouldSendContentAvailable: true)
//    
//    do {
//      try await appDatabase.save(subscription)
//    } catch {
//      print(error)
//    }
//  }
  
  public func value<Property: ICloudProperty>(_ property: Property) async throws -> Property.Value? {
    let recordID = CKRecord.ID(recordName: property.recordID)
    let record = try await database(for: property).record(for: recordID)
    return try parseValue(from: record, for: property)
  }
  
  public func sync<Property: ICloudProperty>(
    property: Property,
    persistenceProperty: some PersistenceProperty<Property.Value>,
    hasLocalUpdates: Bool,
    mergeHandler: @Sendable @escaping (_ localValue: Property.Value, _ cloudValue: Property.Value) -> Property.Value
  ) async throws {
    guard !isSyncing else {
      awatingSync = true
      throw HelloError("Already syncing")
    }
    isSyncing = true
    defer { isSyncing = false }
    
    do {
      guard let identityToken = FileManager.default.ubiquityIdentityToken as? Data else {
        state = .notSignedIn
        throw HelloError("iCloud not available")
      }
      
      let syncState = await Persistence.value(.cloudSyncState)
      var propertyMetadata = syncState?.propertyMetadata[property.recordID] ?? .init(id: .uuid, dateModified: .distantPast)
      
      guard syncState?.token == nil || syncState?.token == identityToken else {
        state = .accountMismatch
        throw HelloError("Cloud account mismatch")
      }
      
      let recordID = CKRecord.ID(recordName: property.recordID)
      var record: CKRecord
      do {
        record = try await database(for: property).record(for: recordID)
      } catch {
        switch error {
        case CKError.unknownItem:
          Log.info("No item found in cloud for \(property.recordID)")
          record = CKRecord(recordType: property.recordType, recordID: recordID)
        case CKError.badDatabase, CKError.badContainer:
          state = .dbError
          throw error
        case CKError.networkFailure, CKError.networkUnavailable:
          state = .networkError
          throw error
        default:
          state = .genericError
          throw error
        }
      }
      
      let cloudMetadata = metadata(for: record) ?? propertyMetadata
      
      state = .ok
      
      //    let container = CKContainer.default()
      //    let containerID = container.value(forKey: "containerID") as! NSObject // CKContainerID
      //    let environment = containerID.value(forKey: "environment")!
      
      guard cloudMetadata.dateModified >= propertyMetadata.dateModified else {
        throw HelloError("Seemingly regressed cloud version for \(property.recordID)")
      }
      
      var value = await Persistence.value(persistenceProperty)
      var needsToUpdateCloud: Bool
      var needsToUpdateLocal: Bool
      if cloudMetadata.id == propertyMetadata.id {
        if hasLocalUpdates {
          Log.verbose("Replacing remote with local for \(property.recordID)", context: "Cloud")
          needsToUpdateCloud = true
          needsToUpdateLocal = false
        } else {
          Log.verbose("No change for \(property.recordID)", context: "Cloud")
          needsToUpdateCloud = false
          needsToUpdateLocal = false
        }
      } else {
        Log.verbose("Merging value for \(property.recordID)", context: "Cloud")
        let cloudObject = try parseValue(from: record, for: property)
        value = mergeHandler(value, cloudObject)
        needsToUpdateCloud = true
        needsToUpdateLocal = true
      }
      
      if needsToUpdateLocal {
        await Persistence.save(value, for: persistenceProperty)
      }
      
      if needsToUpdateCloud {
        Log.verbose("Pushing for \(property.recordID)", context: "Cloud")
        let valueData = try value.jsonData
        switch property.valueType {
        case .data:
          record[assetKey] = valueData
        case .asset:
          let url = FileManager.default.temporaryDirectory.appendingPathComponent("cloud/\(property.recordID).json")
          try valueData.write(to: url)
          record[assetKey] = CKAsset(fileURL: url)
        }
        record = try await database(for: property).save(record)
        guard let updatedMetadata = metadata(for: record) else {
          throw HelloError("Failed to parse updated metadata for \(property.recordID)")
        }
        propertyMetadata = updatedMetadata
      } else {
        Log.verbose("Skipping push for \(property.recordID)", context: "Cloud")
      }
      let updatedMetadata = propertyMetadata
      await Persistence.atomicUpdate(for: .cloudSyncState) {
        var cloudSyncState = $0 ?? .init(token: identityToken)
        cloudSyncState.propertyMetadata[property.recordID] = updatedMetadata
        return cloudSyncState
      }
      Log.info("Sync complete for \(property.recordID)", context: "Cloud")
    } catch {
      Log.error(error.localizedDescription, context: "Cloud")
      throw error
    }
  }
  
  private func database(for property: some ICloudProperty) -> CKDatabase {
    switch property.scope {
    case .app: appDatabase
    case .hello: helloDatabase
    }
  }
  
  private func parseValue<Property: ICloudProperty>(from record: CKRecord, for property: Property) throws -> Property.Value {
    switch property.valueType {
    case .data:
      guard let data = record[assetKey] as? Data else {
        throw HelloError("No data in record for \(String(describing: Property.self))")
      }
      return try Property.Value.decodeJSON(from: data)
    case .asset:
      guard let asset = record[assetKey] as? CKAsset, let fileURL = asset.fileURL else {
        throw HelloError("No asset in record for \(String(describing: Property.self))")
      }
      let data = try Data(contentsOf: fileURL)
      return try Property.Value.decodeJSON(from: data)
    }
  }
  
  private func metadata(for record: CKRecord) -> CloudPropertyMetadata? {
    guard let id = record.recordChangeTag?.id,
          let modificationDate = record.modificationDate else {
      return nil
    }
          
    return CloudPropertyMetadata(id: id, dateModified: modificationDate)
  }
}
