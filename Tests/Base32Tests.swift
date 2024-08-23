import Foundation
import Testing

import HelloCore

@MainActor
final class Base32Tests {
  @Test
  func testParity() throws {
    let base32String = "a7ggfyeh456bbu"
    let decodedData = try Base32.decode(string: base32String)
    let reencodedString = Base32.encode(data: decodedData)
    guard reencodedString == base32String else {
      throw HelloError("Fail base 32 encode/decode parity \(reencodedString)")
    }
  }
}
