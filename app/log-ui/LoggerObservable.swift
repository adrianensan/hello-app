import Foundation
import Combine

import HelloCore

@MainActor
@Observable
public class LoggerObservable: NSObject, LoggerSubscriber, Sendable {
  
  public var lineCount: Int
  let logger: Logger
  @ObservationIgnored public var logStatements: [LogStatement] = []
  
  public init(logger: Logger) {
    self.logger = logger
    lineCount = 0
    super.init()
    
    Task {
      await logger.subscribe(self)
      logStatements = await logger.logStatements
      lineCount = logStatements.count
    }
  }
  
  public func statementLogged(_ statement: LogStatement) {
    logStatements.append(statement)
    lineCount += 1
  }
  
  public func refresh(_ statements: [LogStatement]) {
    logStatements = statements
    lineCount = statements.count
  }
}
