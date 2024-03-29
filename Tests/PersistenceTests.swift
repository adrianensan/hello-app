import XCTest
@testable import HelloCore
@testable import HelloApp

final class HelloAppTests: XCTestCase {
  
  @Persistent(.test) private var test
  
  func testPersistenceThreadSafe() async throws {
    await withTaskGroup(of: Void.self) { taskGroup in
      for _ in 0..<10000 {
        taskGroup.addTask {
          await Persistence.save("test", for: .test)
        }
        taskGroup.addTask {
          await Persistence.save("test1", for: .test)
        }
        taskGroup.addTask {
          _ = await Persistence.value(.test)
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
  
  func testPersistentWrapper() async throws {
    await withTaskGroup(of: Void.self) { taskGroup in
      for _ in 0..<100000 {
        Task {
          self.test = "test3"
        }
        taskGroup.addTask {
          _ = self.test
          self.test = "test"
        }
        taskGroup.addTask {
          self.test = "test1"
          _ = self.test
        }
      }
    }
//    let result = await Persistence.value(.test)
//    XCTAssertEqual(test, "test")
  }
}
