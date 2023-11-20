import Foundation

public enum Log {
  
  #if DEBUG
  public static var shouldPrintStatements: Bool = true
  #else
  public static var shouldPrintStatements: Bool = false
  #endif
  
  public static var ephemeral: Bool = false
  #if DEBUG
  public static var logLevel: LogLevel = .debug
  #else
  public static var logLevel: LogLevel = .info
  #endif
  
  private static var logsFolder: URL {
    ((try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true))
     ?? FileManager.default.temporaryDirectory)
      .appendingPathComponent("Ambient")
      .appendingPathComponent("logs")
  }
  
  public static var logger: Logger = Logger(ephemeral: ephemeral)
  
  private static func log(level: LogLevel, message: String, context: String) {
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
    Task { try await logger.terminate() }
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
}

