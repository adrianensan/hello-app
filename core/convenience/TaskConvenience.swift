import Foundation

extension TimeInterval: Sendable {}

public extension Task where Success == Never, Failure == Never {
  static func sleep(seconds: TimeInterval) async throws {
    try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
  }
  
  static func sleepForOneFrame() async throws {
    try await Task.sleep(nanoseconds: 20_000_000)
  }
}
