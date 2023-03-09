import Foundation

import HelloCore

public struct TestPersistor: PersistenceProperty {
  
  public var defaultValue: String? { nil }
  
  public var location: PersistenceType { .memory }
  
  public var key: TestPersistenceKey { .test }
}

public extension PersistenceProperty where Self == TestPersistor {
  static var test: TestPersistor {
    TestPersistor()
  }
}
