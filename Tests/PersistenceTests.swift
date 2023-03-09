import XCTest
@testable import HelloCore
@testable import HelloApp

final class HelloAppTests: XCTestCase {
  func testPersistenceThreadSafe() async throws {
    await withTaskGroup(of: Void.self) { taskGroup in
      for _ in 0..<10000 {
        taskGroup.addTask {
          await Persistence.save("test", for: .test)
        }
        taskGroup.addTask {
          await Persistence.value(.test)
        }
        taskGroup.addTask {
          await Persistence.atomicUpdate(for: .testInt) {
            $0 + 1
          }
        }
      }
    }
    let result = await Persistence.value(.testInt)
    XCTAssertEqual(result, 10000)
  }
}
