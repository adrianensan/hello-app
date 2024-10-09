import Foundation

@globalActor final public actor HelloLogActor: GlobalActor {
  public static let shared: HelloLogActor = HelloLogActor()
}

public enum Log {
  
  #if DEBUG
  nonisolated(unsafe) private static var shouldPrintStatements: Bool = true
  #else
  nonisolated(unsafe) private static var shouldPrintStatements: Bool = false
  #endif
  
  nonisolated(unsafe) private static var ephemeral: Bool = false
  #if DEBUG
  nonisolated(unsafe) private static var logLevel: LogLevel = .debug
  #else
  nonisolated(unsafe) private static var logLevel: LogLevel = .verbose
  #endif
  
  nonisolated package static let logger: Logger = Logger(ephemeral: ephemeral)
  
  package static func log(level: LogLevel, message: String, context: String?) {
    guard shouldPrintStatements || level >= logLevel else { return }
    let logStatement = LogStatement(level: level, message: message, context: context)
    if shouldPrintStatements {
      print(logStatement.formattedLine)
    }

    if level >= logLevel {
      Task { try await logger.log(logStatement) }
    }
  }
  
  @MainActor
  public static func configure(
    logLevel: LogLevel? = nil,
    shouldPrintStatements: Bool?,
    ephemeral: Bool = false
  ) {
    if let logLevel {
      Self.logLevel = logLevel
    }
    if let shouldPrintStatements {
      Self.shouldPrintStatements = shouldPrintStatements
    }
    Self.ephemeral = ephemeral
    let now: Date = .now
    if logger.dateStarted > now {
      Log.error("Attempted to configure after logger was initialized", context: "Log")
    }
  }
  
  @MainActor
  public static func terminate() {
    logger.terminate()
  }
  
  public static func verbose(_ message: String, context: String? = nil) {
    log(level: .verbose, message: message, context: context)
  }
  
  public static func debug(_ message: String, context: String? = nil) {
    log(level: .debug, message: message, context: context)
  }
  
  public static func info(_ message: String, context: String? = nil) {
    log(level: .info, message: message, context: context)
  }
  
  public static func warning(_ message: String, context: String? = nil) {
    log(level: .warning, message: message, context: context)
  }
  
  public static func error(_ message: String, context: String? = nil) {
    log(level: .error, message: message, context: context)
  }
  
  public static func fatal(_ message: String, context: String? = nil) {
    log(level: .fatal, message: message, context: context)
  }
  
  public static func wtf(_ message: String, context: String? = nil) {
    log(level: .wtf, message: message, context: context)
  }
  
  public static func meta(_ message: String, context: String? = nil) {
    log(level: .meta, message: message, context: context)
  }
  
  public static func crash(_ message: String) {
    try? logger.nonMainUnsafeSyncLog(LogStatement(level: .fatal, message: message, context: "Crash"))
    log(level: .fatal, message: message, context: "Crash")
  }
}

