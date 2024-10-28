import Foundation

/// A lossless condensed and more useful representation of the system UUID
/// 
/// UUID:      36 characters, 1-9 & A-F  XXXXXXXX-XXXX-4XXX-XXXX-XXXXXXXXXXXX
/// HelloUUID: 24 characters, 1-9 & a-z, xxxxxxxxxxxxxxxxxxxxxxxx
///
/// The system UUID contains 122 bits of actual entropy. The remaining 6 bits appear
/// These bits are rearranged into a 128bit int, with the remaining 6 bits being fixed.
/// 0000x1x1xxxxxxxx...
/// These fixed bits ensure the string representation is exactly 24 characters long, with a leading letter
public struct HelloUUID: Identifiable, Hashable, Sendable {
  
  public var bits: UInt128
  
  public init(bits: UInt128) {
    // Set some unused leading bits to force a leading letter
    self.bits = (bits & 0x0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | 0x05000000000000000000000000000000
  }
  
  public var id: UInt128 { bits }
  
  public init() {
    self.init(uuid: UUID())
  }
  
  public init(uuid: UUID) {
    let uuid = uuid.uuid
    // The system UUID contains fixed bits (like the version "4", the 4 leading bits of byte 6),
    // which are stripped out here as they don't provide any entropy.
    let modifiedByte0 = ((uuid.8 & 0b00010000) >> 1) | ((uuid.8 & 0b00100000) >> 4)
    let modifiedByte1 = ((uuid.8 & 0x0F) << 4) | (uuid.6 & 0x0F)
    let bytes = [
      modifiedByte0, modifiedByte1, uuid.0, uuid.1, uuid.2, uuid.3, uuid.4, uuid.5, uuid.7,
      uuid.9, uuid.10, uuid.11, uuid.12, uuid.13, uuid.14, uuid.15]
    let bigEndianUInt = bytes.withUnsafeBytes { $0.load(as: UInt128.self) }
    var value = CFByteOrderGetCurrent() == CFByteOrder(CFByteOrderLittleEndian.rawValue)
    ? UInt128(bigEndian: bigEndianUInt)
    : bigEndianUInt
    
    self.init(bits: value)
  }
  
  public init(string: String) throws {
    guard let bits = UInt128(string, radix: 36) else {
      throw HelloError("Invalid string")
    }
    self.init(bits: bits)
  }
  
  public var string: String {
    String(bits, radix: 36, uppercase: false)
  }
  
  public var shortHashString: String {
    var sum: UInt = 0
    for character in string {
      sum += UInt(String(character), radix: 36) ?? 0
    }
    var subset: UInt32 = 0
    for i in 1 ..< 32 {
      if (bits & 0b1 << (i * 2)).nonzeroBitCount > 0 {
        subset += 0b1 << (i - 1)
      }
    }
    var sumCharacter = String(sum % 36, radix: 36, uppercase: false)
    return "\(sumCharacter)\(String(subset, radix: 36, uppercase: false))"
  }
}
