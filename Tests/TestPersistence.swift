import Foundation

import HelloCore

public enum TestPersistence {
  
  public static let main = HelloPersistence (
    defaultsSuiteName: nil,
    pathRoot: FileManager.default.temporaryDirectory,
    keychain: KeychainHelper(service: "test"))
}
