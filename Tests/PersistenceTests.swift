import Foundation
import Testing

import HelloCore

@MainActor
final class HelloAppTests {
  
  @Persistent(.test) private var test
  @Persistent(.testInt) private var testInt
  @Persistent(.testInt) private var testInt2
  
//  override func setUp() async throws {
//    await Persistence.delete(.test)
//    await Persistence.delete(.testInt)
//    try await Task.sleepForOneFrame()
//  }
  
  @Test
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
    guard result == 10000 else {
      throw HelloError("\(result) should be 10000")
    }
  }
  
  @Test
  func testPersistentWrapper() async throws {
    await withTaskGroup(of: Void.self) { taskGroup in
      for _ in 0..<100000 {
        Task {
          self.test = "test3"
        }
        taskGroup.addTask { @MainActor in
          _ = self.test
          self.test = "test"
        }
        taskGroup.addTask { @MainActor in
          self.test = "test1"
          _ = self.test
        }
      }
    }
//    let result = await Persistence.value(.test)
//    XCTAssertEqual(test, "test")
  }
  
  @Test
  func testPersistentWrapper2() async throws {
    await withTaskGroup(of: Void.self) { taskGroup in
      for _ in 0..<100 {
        testInt += 1
//        taskGroup.addTask {
//          await Persistence.atomicUpdate(for: .testInt) {
////            print($0)
//            return $0 + 1
//          }
//        }
      }
    }
    try await Task.sleep(seconds: 1)
    let result = await Persistence.value(.testInt)
    guard result == 100 && testInt == 100 && testInt2 == 100 else {
      throw HelloError("Fail")
    }
  }
}

fileprivate struct TestIntPersistor: PersistenceProperty {
  
  var defaultValue: Int { 0 }
  
  var location: PersistenceType { .memory(key: "testInt") }
}

fileprivate extension PersistenceProperty where Self == TestIntPersistor {
  static var testInt: TestIntPersistor {
    TestIntPersistor()
  }
}

fileprivate struct TestPersistor: PersistenceProperty {
  
  var defaultValue: String? { nil }
  
  var location: PersistenceType { .memory(key: "testString") }
}

fileprivate extension PersistenceProperty where Self == TestPersistor {
  static var test: TestPersistor {
    TestPersistor()
  }
}
