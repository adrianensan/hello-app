import Foundation

@globalActor final public actor HelloLogActor: GlobalActor {
  public static let shared: HelloLogActor = HelloLogActor()
}

public enum Log {
  
  #if DEBUG
  nonisolated(unsafe) public static var shouldPrintStatements: Bool = true
  #else
  nonisolated(unsafe) public static var shouldPrintStatements: Bool = false
  #endif
  
  nonisolated(unsafe) public static var ephemeral: Bool = false
  #if DEBUG
  nonisolated(unsafe) public static var logLevel: LogLevel = .debug
  #else
  nonisolated(unsafe) public static var logLevel: LogLevel = .info
  #endif
  
  nonisolated public static let logger: Logger = Logger(ephemeral: ephemeral)
  
  nonisolated private static func log(level: LogLevel, message: String, context: String) {
    guard shouldPrintStatements || level >= logLevel else { return }
    let logStatement = LogStatement(level: level, message: message, context: context)
    if shouldPrintStatements {
      print(logStatement.formattedLine)
    }

    if level >= logLevel {
      Task { try await logger.log(logStatement) }
    }
  }
  
  public static func terminate() {
    try? logger.terminate()
  }
  
  public static func verbose(_ message: String, context: String = "") {
    log(level: .verbose, message: message, context: context)
  }
  
  public static func debug(_ message: String, context: String = "") {
    log(level: .debug, message: message, context: context)
  }
  
  public static func info(_ message: String, context: String = "") {
    log(level: .info, message: message, context: context)
  }
  
  public static func warning(_ message: String, context: String = "") {
    log(level: .warning, message: message, context: context)
  }
  
  public static func error(_ message: String, context: String = "") {
    log(level: .error, message: message, context: context)
  }
  
  public static func fatal(_ message: String, context: String = "") {
    log(level: .fatal, message: message, context: context)
  }
  
  public static func wtf(_ message: String, context: String = "") {
    log(level: .wtf, message: message, context: context)
  }
  
  public static func meta(_ message: String, context: String = "") {
    log(level: .meta, message: message, context: context)
  }
  
  public static func crash(_ message: String, context: String = "") {
    try? logger.unsafeSyncLog(LogStatement(level: .fatal, message: message, context: "Crash"))
    log(level: .fatal, message: message, context: "Crash")
  }
}

