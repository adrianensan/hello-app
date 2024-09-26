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
  private let stableIDKey = "stable-id"
  
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
    mergeHandler: @Sendable @escaping (_ localValue: Property.Value, _ cloudValue: Property.Value) async throws -> Property.Value
  ) async throws {
    guard !isSyncing else {
      awatingSync = true
      throw HelloError("Already syncing")
    }
    isSyncing = true
    defer { isSyncing = false }
    
    guard await Persistence.value(.persistenceMode) == .normal else {
      Log.verbose("Skipping sync due to persistence mode", context: "Cloud")
      return
    }
    
    do {
      guard let _ = FileManager.default.ubiquityIdentityToken else {
        state = .notSignedIn
        throw HelloError("iCloud not available")
      }
      
      let syncState = await Persistence.value(.cloudSyncState)
      var propertyMetadata = syncState[property.recordID] ?? .new
      
//      guard syncState?.token == nil || syncState?.token == identityToken else {
//        state = .accountMismatch
//        throw HelloError("Cloud account mismatch")
//      }
      
      let recordID = CKRecord.ID(recordName: property.recordID)
      var record: CKRecord
      do {
        record = try await database(for: property).record(for: recordID)
      } catch {
        switch error {
        case CKError.unknownItem:
          Log.info("No item found for \(property.recordID)", context: "Cloud")
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
      
      let cloudMetadata = metadata(for: record, localMetadata: propertyMetadata) ?? propertyMetadata
      
      state = .ok
      
      //    let container = CKContainer.default()
      //    let containerID = container.value(forKey: "containerID") as! NSObject // CKContainerID
      //    let environment = containerID.value(forKey: "environment")!
      
      guard cloudMetadata.stableID == propertyMetadata.stableID else {
        throw HelloError("Seemingly regressed cloud version for \(property.recordID)")
      }
      
      guard cloudMetadata.dateModified >= propertyMetadata.dateModified else {
        throw HelloError("Seemingly regressed cloud version for \(property.recordID)")
      }
      
      var value = await Persistence.value(persistenceProperty)
      var needsToUpdateCloud: Bool
      var needsToUpdateLocal: Bool
      if cloudMetadata.changeID == propertyMetadata.changeID {
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
        value = try await mergeHandler(value, cloudObject)
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
        guard let updatedMetadata = metadata(for: record, localMetadata: propertyMetadata) else {
          throw HelloError("Failed to parse updated metadata for \(property.recordID)")
        }
        propertyMetadata = updatedMetadata
      } else {
        Log.verbose("Skipping push for \(property.recordID)", context: "Cloud")
      }
      let updatedMetadata = propertyMetadata
      await Persistence.atomicUpdate(for: .cloudSyncState) {
        var state = $0
        state[property.recordID] = updatedMetadata
        return state
      }
      Log.info("Sync complete for \(property.recordID)\nchanged: {local: \(needsToUpdateLocal), remote: \(needsToUpdateCloud)}", context: "Cloud")
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
  
  private func metadata(for record: CKRecord, localMetadata: CloudPropertyMetadata) -> CloudPropertyMetadata? {
    guard let changeID = record.recordChangeTag?.id,
          let modificationDate = record.modificationDate else {
      return nil
    }
          
    return CloudPropertyMetadata(
      stableID: (record[stableIDKey] as? String) ?? localMetadata.stableID,
      changeID: changeID,
      dateModified: modificationDate)
  }
}
