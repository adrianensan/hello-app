import Foundation

public class PersistenceSnapshotGenerator {
  static var systemUserDefaultKeyPrefixes: Set<String> {
    ["NS", "WebKit", "com.apple", "Apple", "INNext", "METAL_", "PK", "CK", "AK"]
  }
  
  static var systemUserDefaultKeys: Set<String> {
    ["cloud.llm", "AddingEmojiKeybordHandled", "InvisibleAutoplayNotPermitted"]
  }
  
}
