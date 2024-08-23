import Foundation
import Testing

import HelloCore

@MainActor
final class HelloUUIDTests {
  @Test
  func testSystemUUIDParity() async throws {
    let uuid = UUID()
    let helloUUID = HelloUUID(uuid: uuid)
    guard helloUUID.systemUUIDString == uuid.uuidString else {
      throw HelloError("Mismatch with system UUID, \(helloUUID.systemUUIDString)")
    }
  }
  
  @Test
  func testLength() async throws {
    let helloUUID = HelloUUID()
    guard helloUUID.string.count == helloUUID.systemUUIDString.count - 11 else {
      throw HelloError("Wrong length \(helloUUID.string.count) \(helloUUID.systemUUIDString.count)")
    }
  }
}
