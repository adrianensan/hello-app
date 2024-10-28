import Foundation
import Combine

import HelloCore

@MainActor
@Observable
public class LoggerModel: LoggerSubscriber, Sendable {
  
  @ObservationIgnored @HelloEnvironmentObject(.logger) private var logger
  
  public var logStatements: [LogStatement] = []
  
  public private(set) var showVerbose: Bool = false
  public private(set) var filter: String?
  
  public private(set) var filters: [String] = []
  
  public init() {}
  
  public func setup() {
    logger.subscribe(self)
    refresh()
    filters = logger.logStatements.compactMap { $0.context }.removingDuplicates().sorted()
  }
  
  public func statementLogged(_ statement: LogStatement) {
    if shouldShow(statement: statement) {
      logStatements.append(statement)
    }
    if let context = statement.context, !filters.contains(context) {
      filters = (filters + [context]).sorted()
    }
  }
  
  public func refresh() {
    logStatements = logger.logStatements.filter { shouldShow(statement: $0) }
  }
  
  public func set(showVerbose: Bool) {
    guard self.showVerbose != showVerbose else { return }
    self.showVerbose = showVerbose
    refresh()
  }
  
  public func set(filter: String?) {
    guard self.filter != filter else { return }
    self.filter = filter
    refresh()
  }
  
  private func shouldShow(statement: LogStatement) -> Bool {
    if let filter, statement.context == filter {
      true
    } else {
      (showVerbose || statement.level > .verbose) && (filter == nil || statement.context == filter)
    }
  }
}
