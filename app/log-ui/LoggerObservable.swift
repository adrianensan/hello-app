import Foundation
import Combine

import HelloCore

@MainActor
@Observable
public class LoggerObservable: NSObject, LoggerSubscriber, Sendable {
  
  let logger: Logger
  public var logStatements: [LogStatement] = []
  
  public init(logger: Logger) {
    self.logger = logger
    super.init()
    
    Task {
      await logger.subscribe(self)
      logStatements = await logger.logStatements
    }
  }
  
  public func statementLogged(_ statement: LogStatement) {
    logStatements.append(statement)
  }
  
  public func refresh(_ statements: [LogStatement]) {
    logStatements = statements
  }
}
