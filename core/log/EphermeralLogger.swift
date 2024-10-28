import Foundation

@MainActor
public class EphemeralLogger: Sendable {
  
  var logStatements: [LogStatement] { [] }
  
  func log(_ logStatement: LogStatement) async throws {}
  func unsafeSyncLog(_ logStatement: LogStatement) {}
  
  func subscribe(_ subscriber: some LoggerSubscriber) {}
  
  func generateRawString() -> String { "" }
  
  func clear() async throws {}
  func flush() async throws {}
}
