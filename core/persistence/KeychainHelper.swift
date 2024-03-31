import Foundation

public class KeychainHelper {
  
  public enum KeychainError: LocalizedError {
    case notFound
    case invalidValue
    case saveError
    case other(error: OSStatus)
    
    public var errorDescription: String? {
      switch self {
      case .notFound:
        "Keychain item not found"
      case .invalidValue:
        "Keychain item has wrong value type"
      case .saveError:
        "Keychain item failed to save"
      case .other(let error):
        "Keychain error \(error)"
      }
    }
  }
  
  private let service: String
  
  private let accessGroup: String?
  
  private static var _bioSecAccessControl: SecAccessControl?
  public static var bioSecAccessControl: SecAccessControl {
    get throws {
      if let _bioSecAccessControl {
        return _bioSecAccessControl
      } else {
        guard let access = SecAccessControlCreateWithFlags(
          nil,
          kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
          .biometryCurrentSet,
          nil)
        else { throw HelloError("Failed to create Biometrics accesss control") }
        _bioSecAccessControl = access
        return access
      }
    }
  }
  
  private var baseAttributes: [CFString: Any] {
    var attributes: [CFString: Any] = [
      kSecAttrService: accessGroup ?? service,
      kSecClass: kSecClassGenericPassword
    ]
    return attributes
  }
  
  public init(service: String, group: String? = nil) {
    self.service = service
    accessGroup = group
  }
  
  private func queryAttributes(for key: String) -> [CFString: Any] {
    var query = baseAttributes
    query[kSecAttrAccount] = key
    return query
  }
  
  // MARK: Password
  
  public func set(_ value: String, for key: String, appGroup: Bool, isBiometricallyLocked: Bool) throws {
    guard value != (try? string(for: key)) else { return }
    guard let data = value.data(using: .utf8) else {
      throw KeychainError.invalidValue
    }
    
    try set(data, for: key, appGroup: appGroup, isBiometricallyLocked: isBiometricallyLocked)
  }
  
  public func set(_ data: Data, for key: String, appGroup: Bool, isBiometricallyLocked: Bool) throws {
    #if os(iOS) || os(macOS) || os(watchOS)
    try? remove(for: key)
    
    var query = baseAttributes
    query[kSecAttrAccount] = key
    query[kSecValueData] = data
    query[kSecUseDataProtectionKeychain] = true
    if appGroup, let accessGroup = accessGroup {
      query[kSecAttrAccessGroup] = accessGroup
    }
    if isBiometricallyLocked, let accessControl = try? Self.bioSecAccessControl {
      query[kSecAttrAccessControl] = accessControl
    } else {
      query[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlock
    }
    
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
      switch status {
      case errSecDuplicateItem:
        let updateStatus = SecItemUpdate(queryAttributes(for: key) as CFDictionary, [
          kSecValueData: data,
          kSecUseDataProtectionKeychain: true
        ] as [CFString : Any] as CFDictionary)
        guard status == errSecSuccess else {
          switch status {
          default: throw KeychainError.other(error: status)
          }
        }
        return
      default: throw KeychainError.other(error: status)
      }
    }
    #else
    fatalError("Keychain Not Available")
    #endif
  }
  
  public func remove(for key: String) throws {
    #if os(iOS) || os(macOS) || os(watchOS)
    let status = SecItemDelete(queryAttributes(for: key) as CFDictionary)
    guard status == errSecSuccess else {
      switch status {
      default: throw KeychainError.other(error: status)
      }
    }
    #else
    fatalError("Keychain Not Available")
    #endif
  }
  
  public func string(for key: String, additionalAttributes: [CFString: Any] = [:]) throws -> String {
    let data = try data(for: key, additionalAttributes: additionalAttributes)
    guard let string = String(data: data, encoding: .utf8) else {
      throw KeychainError.invalidValue
    }
    return string
  }
  
  public func data(for key: String, additionalAttributes: [CFString: Any] = [:]) throws -> Data {
    #if os(iOS) || os(macOS) || os(watchOS)
    var query = baseAttributes
    query[kSecAttrAccount] = key
    query[kSecMatchLimit] = kSecMatchLimitOne
    query[kSecReturnData] = true
    query[kSecUseAuthenticationUI] = kSecUseAuthenticationUIAllow
    for (key, value) in additionalAttributes {
      query[key] = value
    }
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    guard status == errSecSuccess else {
      switch status {
      default: throw KeychainError.other(error: status)
      }
    }
    guard let data = result as? Data else {
      throw KeychainError.invalidValue
    }
    return data
    #else
    fatalError("Keychain Not Available")
    #endif
  }
  
  public func nuke() {
    #if os(iOS) || os(macOS) || os(watchOS)
    SecItemDelete(baseAttributes as CFDictionary)
    #else
    fatalError("Keychain Not Available")
    #endif
  }
}
