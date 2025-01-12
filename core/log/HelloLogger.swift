import Foundation

@MainActor
public class HelloLogger: Logger {
  
  public private(set) var logStatements: [LogStatement]
  public weak var subscriber: (any LoggerSubscriber)?
  
  private var lastLoggedTime: TimeInterval = epochTime
  private var isFlushPending: Bool = true
  
  nonisolated public init() {
    self.logStatements = Persistence.unsafeValue(.logs)
    logStatements.append(LogStatement(level: .meta, context: "App", preview: nil, message: "Launch ------------------"))
    Task { try await softFlush() }
  }
  
  public func generateRawString() -> String {
    logStatements.reduce("") { $0 + $1.formattedLine + "\n" }
  }
  
  public func log(_ logStatement: LogStatement) async throws {
    logStatements.append(logStatement)
    self.lastLoggedTime = epochTime
    self.subscriber?.statementLogged(logStatement)
    if !self.isFlushPending {
      self.isFlushPending = true
      try await softFlush()
    }
  }
  
  nonisolated public func nonMainUnsafeSyncLog(_ logStatement: LogStatement) throws {
    var logStatements = Persistence.unsafeValue(.logs)
    logStatements.append(logStatement)
    Persistence.unsafeSave(logStatements, for: .logs)
  }
  
  public func unsafeSyncLog(_ logStatement: LogStatement) {
    logStatements.append(logStatement)
    unsafeSyncFlush()
  }
  
  nonisolated public func unsafeLog() async {
    await Persistence.save(logStatements, for: .logs)
  }
  
  public func terminate() {
    unsafeSyncLog(LogStatement(level: .meta, context: "App", preview: nil, message: "Terminate ---------------"))
  }
  
  public func clear() async throws {
    logStatements = []
    subscriber?.refresh()
    if !isFlushPending {
      isFlushPending = true
      try await softFlush()
    }
  }
  
  public func subscribe(_ subscriber: some LoggerSubscriber) {
    self.subscriber = subscriber
  }
  
  public func softFlush() async throws {
    guard isFlushPending else { return }
    var diff = epochTime - lastLoggedTime
    while diff < 5 {
      try await Task.sleep(seconds: 5 - diff)
      diff = epochTime - lastLoggedTime
    }
    isFlushPending = false
    let oldestAllowed = epochTime - 60 * 60 * 24 * 7
    let filteredLogStatements = Array(logStatements.drop(while: { $0.timeStamp < oldestAllowed }).suffix(2500))
    if logStatements.first?.id != filteredLogStatements.first?.id {
      logStatements = filteredLogStatements
      subscriber?.refresh()
    }
    await flushReal()
  }
  
  public func flush() async throws {
    await flushReal()
    isFlushPending = false
  }
  
  nonisolated private func flushReal() async {
    await Persistence.save(logStatements, for: .logs)
  }
  
  private func unsafeSyncFlush() {
    Persistence.unsafeSave(logStatements, for: .logs)
  }
}
