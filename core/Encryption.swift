import Foundation
import CryptoKit
import CommonCrypto

import HelloCore

public struct EncryptedData: Codable, Sendable {
  var data: Data
  var salt: Data
  var pepper: Data
}

@globalActor final public actor EncryptionActor: GlobalActor {
  public static let shared: EncryptionActor = EncryptionActor()
}

@EncryptionActor
public enum Encryption {
  public static func encrypt(data: Data, with password: String) throws -> EncryptedData {
    let salt = try randomSalt
    let pepper = try randomSalt
    let key = try key(from: password, salt: salt, pepper: pepper)
    guard let encryptedData = try AES.GCM.seal(data, using: key).combined else {
      throw HelloError("Failed to encrypt")
    }
    return EncryptedData(data: encryptedData, salt: salt, pepper: pepper)
  }
  
  public static func decrypt(data: EncryptedData, with password: String) throws -> Data {
    let key = try key(from: password, salt: data.salt, pepper: data.pepper)
    let sealedBox = try AES.GCM.SealedBox(combined: data.data)
    return try AES.GCM.open(sealedBox, using: key)
  }
  
  public static func sha512(_ string: String, salt: Data) throws -> Data {
    guard let stringData = string.data(using: .utf8) else {
      Log.wtf("Failed to get data from string", context: "Encryption")
      throw HelloError("Failed to get data from password")
    }
    return Data(SHA256.hash(data: stringData + salt))
  }
  
  nonisolated public static var randomBytes: [UInt8] {
    get throws {
      var buffer: [UInt8] = .init(repeating: 0, count: SHA512.byteCount)
      guard SecRandomCopyBytes(kSecRandomDefault, SHA512.byteCount, &buffer) == 0 else {
        Log.wtf("Failed to generate random bytes", context: "Encryption")
        throw HelloError("Failed to generate random bytes")
      }
      return buffer
    }
  }
  
  public static var randomSalt: Data {
    get throws {
      return Data(try randomBytes)
    }
  }
  
  private static func key(from password: String, salt: Data, pepper: Data) throws -> SymmetricKey {
    guard let passwordCharacters = password.cString(using: .utf8) else {
      Log.wtf("Failed to generate C string from password", context: "Encryption")
      throw HelloError("Failed to get c string from password")
    }
    
    var derivedKeyData: [UInt8] = .init(repeating: 0, count: SHA256.byteCount)
    
    CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),
                         passwordCharacters,
                         passwordCharacters.count,
                         [UInt8](salt),
                         salt.count,
                         CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512),
                         806_911,
                         &derivedKeyData,
                         derivedKeyData.count)
    
    let derivedKey = SymmetricKey(data: derivedKeyData)
    
    let key = HKDF<SHA256>.deriveKey(
      inputKeyMaterial: derivedKey,
      salt: pepper,
      outputByteCount: SHA256.byteCount)
    return key
  }
}
