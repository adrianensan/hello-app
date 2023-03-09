import Foundation

import HelloCore

public struct TestIntPersistor: PersistenceProperty {
  
  public var defaultValue: Int { 0 }
  
  public var location: PersistenceType { .memory }
  
  public var key: TestPersistenceKey { .testInt }
}

public extension PersistenceProperty where Self == TestIntPersistor {
  static var testInt: TestIntPersistor {
    TestIntPersistor()
  }
}
