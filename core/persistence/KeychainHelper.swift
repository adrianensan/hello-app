import Foundation

public class KeychainHelper {
  
  public enum KeychainError: Error {
    case notFound
    case invalidValue
    case saveError
    case other(error: OSStatus)
  }
  
  private let service: String
  
  private let accessGroup: String?
  
  #if os(iOS) || os(macOS)
  private var baseAttributes: [CFString: Any] {
    var attributes: [CFString: Any] = [
      kSecAttrService: service,
      kSecClass: kSecClassGenericPassword
    ]
    if let accessGroup = accessGroup {
      attributes[kSecAttrAccessGroup] = accessGroup
    }
    return attributes
  }
  #endif
  
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
  
  public func set(_ value: String, for key: String) throws {
    guard value != (try? string(for: key)) else { return }
    guard let data = value.data(using: .utf8) else {
      throw KeychainError.invalidValue
    }
    
    try set(data, for: key)
  }
  
  public func set(_ data: Data, for key: String) throws {
    #if os(iOS) || os(macOS)
    try? remove(for: key)
    
    var query = baseAttributes
    query[kSecAttrAccount] = key
    query[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlock
    query[kSecValueData] = data
    query[kSecUseDataProtectionKeychain] = true
    
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
      switch status {
      case errSecDuplicateItem:
        let updateStatus = SecItemUpdate(queryAttributes(for: key) as CFDictionary,
                                         [kSecValueData: data,
                                          kSecUseDataProtectionKeychain: true] as CFDictionary)
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
  
  @discardableResult public func remove(for key: String) throws {
    #if os(iOS) || os(macOS)
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
  
  public func string(for key: String) throws -> String {
    let data = try data(for: key)
    guard let string = String(data: data, encoding: .utf8) else {
      throw KeychainError.invalidValue
    }
    return string
  }
  
  public func data(for key: String) throws -> Data {
    #if os(iOS) || os(macOS)
    var query = baseAttributes
    query[kSecAttrAccount] = key
    query[kSecMatchLimit] = kSecMatchLimitOne
    query[kSecReturnData] = true
    
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
    #if os(iOS) || os(macOS)
    SecItemDelete(baseAttributes as CFDictionary)
    #else
    fatalError("Keychain Not Available")
    #endif
  }
}
