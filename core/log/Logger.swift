import Foundation

@MainActor
public protocol LoggerSubscriber: AnyObject, Sendable {
  func statementLogged(_: LogStatement)
  func refresh()
}

@MainActor
public class Logger: Sendable {
  
  public static let shared = Logger()
  public let dateStarted: Date = .now
  
  public private(set) var logStatements: [LogStatement]
  public weak var subscriber: (any LoggerSubscriber)?
  
  private var lastLoggedTime: TimeInterval = epochTime
  private var isFlushPending: Bool = true
  private var isEphemeral: Bool = false
  
  nonisolated public init(ephemeral: Bool = false) {
    self.isEphemeral = ephemeral
    if !ephemeral {
      self.logStatements = Persistence.unsafeValue(.logs)
    } else {
      logStatements = []
    }
    
    logStatements.append(LogStatement(level: .meta, message: "Launch ------------------", context: "App"))
    Task { try await flush(force: false) }
  }
  
  public func generateRawString() -> String {
    logStatements.reduce("") { $0 + $1.formattedLine + "\n" }
  }
  
  public func log(_ logStatement: LogStatement) async throws {
    logStatements.append(logStatement)
    guard !isEphemeral else { return }
    self.lastLoggedTime = epochTime
    self.subscriber?.statementLogged(logStatement)
    if !self.isFlushPending {
      self.isFlushPending = true
      try await flush(force: false)
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
  
  public func terminate() {
    unsafeSyncLog(LogStatement(level: .meta, message: "Terminate ---------------", context: "App"))
  }
  
  public func clear() async throws {
    logStatements = []
    subscriber?.refresh()
    if !isFlushPending {
      isFlushPending = true
      try await flush(force: false)
    }
  }
  
  public func subscribe(_ subscriber: some LoggerSubscriber) {
    self.subscriber = subscriber
  }
  
  public func flush(force: Bool = false) async throws {
    guard !force else {
      await flushReal(logStatements: logStatements)
      isFlushPending = false
      return
    }
    guard isFlushPending else { return }
    var diff = epochTime - lastLoggedTime
    while diff < 5 {
      try await Task.sleep(seconds: 5 - diff)
      diff = epochTime - lastLoggedTime
    }
    isFlushPending = false
    let oldestAllowed = epochTime - 60 * 60 * 24
    let filteredLogStatements = Array(logStatements.drop(while: { $0.timeStamp < oldestAllowed }).suffix(2000))
    if logStatements.first?.id != filteredLogStatements.first?.id {
      logStatements = filteredLogStatements
      subscriber?.refresh()
    }
    await flushReal(logStatements: logStatements)
  }
  
  nonisolated private func flushReal(logStatements: [LogStatement]) async {
    await Task.detached {
      await Persistence.save(logStatements, for: .logs)
    }.value
  }
  
  private func unsafeSyncFlush() {
    Persistence.unsafeSave(logStatements, for: .logs)
  }
}
