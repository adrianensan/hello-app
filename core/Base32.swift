import Foundation

public enum Base32 {
  
  public enum Base32Error: Error {
    case invalidCharacters
  }
  
  private static var characters: [Character] { [Character]("abcdefghijklmnopqrstuvwxyz234567") }
  
  public static func decode(string base32String: String) throws(Base32Error) -> Data {
    var bytes: [UInt8] = []
    var phase = true
    var byte: UInt8 = 0
    for character in base32String.lowercased() {
      guard let value = characters.firstIndex(of: character) else { throw .invalidCharacters }
      if phase {
        byte = UInt8(value)
        byte <<= 4
      } else {
        byte |= UInt8(value)
        bytes.append(byte)
      }
      
      phase.toggle()
    }
    if !phase {
      bytes.append(byte)
    }
    return Data(bytes)
  }
  
  public static func decode(data base32Data: Data) throws(Base32Error) -> Data {
    guard let string = String(data: base32Data, encoding: .utf8) else { throw .invalidCharacters }
    return try decode(string: string)
  }
  
  public static func encode(data: Data) -> String {
    var base32String = ""
    
    var bitIndex = data.count * 8 - 1
    while bitIndex > 0 {
      var value = 0
      for i in 0..<5 {
        if bitIndex > 0 && (data[bitIndex / 8] >> (7 - bitIndex % 8)) & 0x01 != 0 {
          value += Int(pow(2, Double(i)))
        }
        bitIndex -= 1
      }
      base32String.append(characters[value])
    }
    return String(base32String.reversed())
  }
}
