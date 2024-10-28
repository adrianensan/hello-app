import Foundation

@MainActor
public protocol LoggerSubscriber: AnyObject, Sendable {
  func statementLogged(_: LogStatement)
  func refresh()
}

@MainActor
public protocol Logger: Sendable {
  
  var logStatements: [LogStatement] { get }
  
  func log(_ logStatement: LogStatement) async throws
  func unsafeSyncLog(_ logStatement: LogStatement)
  
  func subscribe(_ subscriber: some LoggerSubscriber)
  
  func generateRawString() -> String
  
  func clear() async throws
  func flush() async throws
}

public struct LoggerHelloEnvironmentKey: HelloEnvironmentObjectKey {
  public static let defaultValue: any Logger = HelloLogger()
}

public extension HelloEnvironmentObjectKey where Self == LoggerHelloEnvironmentKey {
  static var logger: LoggerHelloEnvironmentKey { LoggerHelloEnvironmentKey() }
}
