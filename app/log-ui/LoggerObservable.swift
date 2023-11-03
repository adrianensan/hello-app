import Foundation
import Combine

import HelloCore

@MainActor
@Observable
public class LoggerObservable: NSObject, LoggerSubscriber {
  
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
  
  public func statementLogged() {
    Task {
      logStatements = await logger.logStatements
      self.lineCount += 1
    }
  }
}
