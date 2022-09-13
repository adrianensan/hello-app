import Foundation

import HelloCore

@MainActor
public class LoggerObservable: NSObject, ObservableObject, LoggerSubscriber {
  
  @Published public var lineCount: Int
  var logger: Logger
  public var logStatements: [LogStatement] = []
  
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
