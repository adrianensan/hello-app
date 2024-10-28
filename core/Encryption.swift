import Foundation
import CryptoKit
import CommonCrypto

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
    try SyncEncryption.encrypt(data: data, with: password)
  }
  
  public static func decrypt(data: EncryptedData, with password: String) throws -> Data {
    try SyncEncryption.decrypt(data: data, with: password)
  }
  
  public static func sha512(_ string: String, salt: Data) -> Data {
    SyncEncryption.sha512(string, salt: salt)
  }
  
  public static func sha256(_ string: String, salt: Data) -> Data {
    SyncEncryption.sha256(string, salt: salt)
  }
  
  nonisolated public static var randomBytes: [UInt8] {
    get throws { try SyncEncryption.randomBytes }
  }
  
  public static var randomSalt: Data {
    get throws { try SyncEncryption.randomSalt }
  }
}

public enum SyncEncryption {
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
  
  public static func sha256(_ string: String, salt: Data) -> Data {
    Data(SHA256.hash(data: string.data + salt))
  }
  
  public static func sha512(_ string: String, salt: Data) -> Data {
    Data(SHA512.hash(data: string.data + salt))
  }
  
  nonisolated public static var randomBytes: [UInt8] {
    get throws {
      var buffer: [UInt8] = .init(repeating: 0, count: SHA512.byteCount)
      guard SecRandomCopyBytes(kSecRandomDefault, SHA512.byteCount, &buffer) == 0 else {
        Log.wtf(context: "Encryption", "Failed to generate random bytes")
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
    let derivedKeyData = try generatePBKDF(password: password, salt: salt)
    
    let derivedKey = SymmetricKey(data: derivedKeyData)
    
    let key = HKDF<SHA256>.deriveKey(
      inputKeyMaterial: derivedKey,
      salt: pepper,
      outputByteCount: SHA256.byteCount)
    return key
  }
  
  private static func generatePBKDF(password: String, salt: Data) throws -> [UInt8] {
    guard let passwordCharacters = password.cString(using: .utf8) else {
      Log.wtf(context: "Encryption", "Failed to generate C string from password")
      throw HelloError("Failed to get c string from password")
    }
    var derivedKeyData: [UInt8] = .init(repeating: 0, count: SHA256.byteCount)
    KeyDerivationPBKDF(
      algorithm: CCPBKDFAlgorithm(kCCPBKDF2),
      password: passwordCharacters,
      passwordLen: passwordCharacters.count,
      salt: [UInt8](salt),
      saltLen: salt.count,
      prf: CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512),
      rounds: 806_911,
      derivedKey: &derivedKeyData,
      derivedKeyLen: derivedKeyData.count)
    return derivedKeyData
  }
  
  public static func KeyDerivationPBKDF(
    algorithm: CCPBKDFAlgorithm,
    password: UnsafePointer<CChar>!,
    passwordLen: Int,
    salt: UnsafePointer<UInt8>!,
    saltLen: Int,
    prf: CCPseudoRandomAlgorithm,
    rounds: UInt32,
    derivedKey: UnsafeMutablePointer<UInt8>!,
    derivedKeyLen: Int) -> Int32 {
      CCKeyDerivationPBKDF(algorithm,
                           password,
                           passwordLen,
                           salt,
                           saltLen,
                           prf,
                           rounds,
                           derivedKey,
                           derivedKeyLen)
      
    }
}
