import Foundation

@globalActor final public actor HelloLogActor: GlobalActor {
  public static let shared: HelloLogActor = HelloLogActor()
}

@MainActor
public enum Log {
  
  #if DEBUG
  private static var shouldPrintStatements: Bool = true
  #else
  private static var shouldPrintStatements: Bool = false
  #endif
  
  private static var ephemeral: Bool = false
  #if DEBUG
  private static var logLevel: LogLevel = .debug
  #else
  private static var logLevel: LogLevel = .verbose
  #endif
  
  package static func log(level: LogLevel, context: @escaping @Sendable () -> String?,
                          message: @escaping @Sendable () -> String) async throws {
    guard shouldPrintStatements || level >= logLevel else { return }

    let logStatement = LogStatement(level: level, context: context(), message: message())
    if shouldPrintStatements {
      print(logStatement.formattedLine)
    }
    
    if level >= logLevel {
      try await HelloEnvironment.object(for: .logger).log(logStatement)
    }
  }
  
  public static func configure(
    fileURL: URL? = nil,
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
  }
  
  nonisolated public static func log(level: LogLevel, context: @escaping @Sendable () -> String?, message: @escaping @Sendable () -> String) {
    Task { @MainActor in
      try await log(level: level, context: context, message: message)
    }
  }
  
  public static func terminate() {
    HelloEnvironment.object(for: .logger).unsafeSyncLog(LogStatement(level: .meta, context: "App", message: "Terminate ---------------"))
  }
  
  nonisolated public static func verbose(context: @escaping @autoclosure @Sendable () -> String? = nil,
                                         _ message: @escaping @autoclosure @Sendable () -> String) {
    log(level: .verbose, context: context, message: message)
  }
  
  nonisolated public static func debug(context: @escaping @autoclosure @Sendable () -> String? = nil,
                                       _ message: @escaping @autoclosure @Sendable () -> String) {
    log(level: .debug, context: context, message: message)
  }
  
  nonisolated public static func info(context: @escaping @autoclosure @Sendable () -> String? = nil,
                                      _ message: @escaping @autoclosure @Sendable () -> String) {
    log(level: .info, context: context, message: message)
  }
  
  nonisolated public static func warning(context: @escaping @autoclosure @Sendable () -> String? = nil,
                                         _ message: @escaping @autoclosure @Sendable () -> String) {
    log(level: .warning, context: context, message: message)
  }
  
  nonisolated public static func error(context: @escaping @autoclosure @Sendable () -> String? = nil,
                                       _ message: @escaping @autoclosure @Sendable () -> String) {
    log(level: .error, context: context, message: message)
  }
  
  nonisolated public static func fatal(context: @escaping @autoclosure @Sendable () -> String? = nil,
                                       _ message: @escaping @autoclosure @Sendable () -> String) {
    log(level: .fatal, context: context, message: message)
  }
  
  nonisolated public static func wtf(context: @escaping @autoclosure @Sendable () -> String? = nil,
                                     _ message: @escaping @autoclosure @Sendable () -> String) {
    log(level: .wtf, context: context, message: message)
  }
  
  nonisolated public static func meta(context: @escaping @autoclosure @Sendable () -> String? = nil,
                                      _ message: @escaping @autoclosure @Sendable () -> String) {
    log(level: .meta, context: context, message: message)
  }
  
  nonisolated public static func crash(_ message: @escaping @autoclosure @Sendable () -> String) {
    //    try? logger.nonMainUnsafeSyncLog(LogStatement(level: .fatal, message: message, context: "Crash"))
    log(level: .fatal, context: { "Crash" }, message: message)
  }
}

