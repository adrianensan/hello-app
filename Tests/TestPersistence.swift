import Foundation

import HelloCore

public enum TestPersistenceKey: Hashable, PersistenceKey {
  
  public static var persistence: HelloPersistence<TestPersistenceKey> { TestPersistence.main }
  
  case test
  case testInt
}

public enum TestPersistence {
  
  public static let main = HelloPersistence<TestPersistenceKey>(
    defaultsSuiteName: nil,
    pathRoot: FileManager.default.temporaryDirectory,
    keychain: KeychainHelper(service: "test"))
}
