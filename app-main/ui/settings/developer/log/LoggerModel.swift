import Foundation
import Combine

import HelloCore

@MainActor
@Observable
public class LoggerModel: LoggerSubscriber, Sendable {
  
  let logger: Logger
  public var logStatements: [LogStatement] = []
  
  public private(set) var showVerbose: Bool = false
  public private(set) var filter: String?
  
  public init(logger: Logger) {
    self.logger = logger
    refresh()
  }
  
  public func setup() {
    logger.subscribe(self)
  }
  
  public func statementLogged(_ statement: LogStatement) {
    if showVerbose || statement.level > .verbose {
      logStatements.append(statement)
    }
  }
  
  public func refresh() {
    logStatements = logger.logStatements.filter {
      (showVerbose || $0.level > .verbose) &&
      (filter == nil || $0.context == filter)
    }
  }
  
  public func set(showVerbose: Bool) {
    guard self.showVerbose != showVerbose else { return }
    self.showVerbose = showVerbose
    refresh()
  }
  
  public func set(filter: String) {
    guard self.filter != filter else { return }
    self.filter = filter
    refresh()
  }
}
