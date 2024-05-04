import Foundation

@MainActor
public protocol LoggerSubscriber: AnyObject {
  func statementLogged()
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
      self.logStatements = Persistence.initialValue(.logs)
    } else {
      logStatements = []
    }
    
    logStatements.append(LogStatement(level: .meta, message: "", context: "-----Launch-----"))
    Task { try await flush() }
  }
  
  private func generateRawString() -> String {
    logStatements.reduce("") { $0 + $1.formattedLine + "\n" }
  }
  
  public func log(_ logStatement: LogStatement) async throws {
    logStatements.append(logStatement)
    guard !isEphemeral else { return }
    self.lastLoggedTime = epochTime
    Task { await self.subscriber?.statementLogged() }
    if !self.isFlushPending {
      self.isFlushPending = true
      try await flush()
    }
  }
  
  public func terminate() async throws {
    try await log(LogStatement(level: .meta, message: "", context: "-----Terminate-----"))
    try await flush(force: true)
    isEphemeral = true
  }
  
  public func clear() async throws {
    logStatements = []
    Task { await subscriber?.statementLogged() }
    if !isFlushPending {
      isFlushPending = true
      try await flush()
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
    logStatements = Array(logStatements.drop(while: { $0.timeStamp < oldestAllowed }))
    await flushReal()
  }
  
  private func flushReal() async {
    await Persistence.save(logStatements, for: .logs)
  }
}
