import Foundation

public struct HelloUUID: Identifiable, Hashable, Sendable {
  
  public var bits: UInt128
  
  public init(bits: UInt128) {
    self.bits = (bits & 0x0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | 0x05000000000000000000000000000000
  }
  
  public var id: UInt128 { bits }
  
  public init() {
    self.init(uuid: UUID())
  }
  
  public init(uuid: UUID) {
    let uuid = uuid.uuid
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
  
  public static func read(uuidString: String) throws -> HelloUUID {
    guard let uuid = UUID(uuidString: uuidString) else {
      throw HelloError("Invalid hexadecimal value")
    }
    return HelloUUID(uuid: uuid)
  }
  
  public var string: String {
    String(bits, radix: 36, uppercase: false)
//    var raw = String(bits, radix: 36, uppercase: false)
//    let diff = 24 - raw.count
//    if diff > 0 {
//      raw = String(repeatElement("0", count: diff)) + raw
//    }
//    guard let firstCharacter = raw.first else {
//      Log.wtf("Empty HelloUUID string")
//      return raw
//    }
//    guard let index = characters.firstIndex(of: firstCharacter) else {
//      Log.wtf("Unexpected character \(firstCharacter) in HelloUUID")
//      return raw
//    }
//    let modifiedIndex = index + 27
//    guard modifiedIndex < characters.count else {
//      Log.wtf("First character in HelloUUID is too large (\(firstCharacter))")
//      return raw
//    }
//    raw = String(characters[modifiedIndex]) + raw.dropFirst()
//    return raw
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
  
  public var systemUUIDString: String {
    var uuid = String(bits, radix: 16, uppercase: true)
    uuid.insert("-", at: uuid.index(for: 20))
    uuid.insert("-", at: uuid.index(for: 16))
    uuid.insert("-", at: uuid.index(for: 12))
    uuid.insert("-", at: uuid.index(for: 8))
    return uuid
  }
  
  public var systemUUID: UUID? {
    UUID(uuidString: systemUUIDString)
  }
  
//  func nowTime() -> String {
//    let epochTime = Date.now.timeIntervalSince1970
//    var int = UInt64(epochTime)
//    print(int)
//    
//    var bits: [Bool] = []
//    for _ in 0..<35 {
//      let currentBit = int & 0x01
//      bits.append(currentBit != 0)
//      int >>= 1
//    }
//    
//    bits.reverse()
//    
//    var string = ""
//    while !bits.isEmpty {
//      var value = 0
//      for i in 0..<5 {
//        if bits.popLast() == true {
//          value += Int(pow(2, Double(i)))
//        }
//      }
//      string.append(Self.lowercasedCharacters[value])
//    }
//    return String(string.reversed())
//  }
}
