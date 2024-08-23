import Foundation
import Combine

import HelloCore

@MainActor
@Observable
public class LoggerModel: LoggerSubscriber, Sendable {
  
  let logger: Logger
  public var logStatements: [LogStatement] = []
  
  public init(logger: Logger) {
    self.logger = logger
    logStatements = logger.logStatements
  }
  
  public func setup() {
    logger.subscribe(self)
  }
  
  public func statementLogged(_ statement: LogStatement) {
    logStatements.append(statement)
  }
  
  public func refresh(_ statements: [LogStatement]) {
    logStatements = statements
  }
}
