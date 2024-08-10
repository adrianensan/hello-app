import Foundation

@MainActor
public protocol LoggerSubscriber: AnyObject, Sendable {
  func statementLogged(_: LogStatement)
  func refresh(_: [LogStatement])
}

public actor Logger: Sendable {
  
  public static let shared = Logger()
  
  public private(set) var logStatements: [LogStatement]
  public weak var subscriber: (any LoggerSubscriber)?
  
  private var lastLoggedTime: TimeInterval = epochTime
  private var isFlushPending: Bool = true
  private var isEphemeral: Bool = false
  
  public init(ephemeral: Bool = false) {
    self.isEphemeral = ephemeral
    if !ephemeral {
      self.logStatements = Persistence.unsafeValue(.logs)
    } else {
      logStatements = []
    }
    
    logStatements.append(LogStatement(level: .meta, message: "", context: "-----Launch-----"))
    Task { try await flush(force: false) }
  }
  
  private func generateRawString() -> String {
    logStatements.reduce("") { $0 + $1.formattedLine + "\n" }
  }
  
  public func log(_ logStatement: LogStatement) async throws {
    logStatements.append(logStatement)
    guard !isEphemeral else { return }
    self.lastLoggedTime = epochTime
    Task { await self.subscriber?.statementLogged(logStatement) }
    if !self.isFlushPending {
      self.isFlushPending = true
      try await flush(force: false)
    }
  }
  
  nonisolated public func unsafeSyncLog(_ logStatement: LogStatement) throws {
    var logStatements = Persistence.unsafeValue(.logs)
    logStatements.append(logStatement)
    Persistence.unsafeSave(logStatements, for: .logs)
  }
  
  nonisolated public func terminate() throws {
    try unsafeSyncLog(LogStatement(level: .meta, message: "", context: "-----Terminate-----"))
  }
  
  public func clear() async throws {
    logStatements = []
    Task { await subscriber?.refresh([]) }
    if !isFlushPending {
      isFlushPending = true
      try await flush(force: false)
    }
  }
  
  public func subscribe(_ subscriber: any LoggerSubscriber) {
    self.subscriber = subscriber
  }
  
  public func flush(force: Bool = false) async throws {
    guard !force else {
      await flushReal()
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
    let oldestAllowed = epochTime - 60 * 60 * 24 * 2
    let filteredLogStatements = Array(logStatements.drop(while: { $0.timeStamp < oldestAllowed }))
    if logStatements.first?.id != filteredLogStatements.first?.id {
      await subscriber?.refresh(filteredLogStatements)
      logStatements = filteredLogStatements
    }
    await flushReal()
  }
  
  private func flushReal() async {
    await Persistence.save(logStatements, for: .logs)
  }
}
