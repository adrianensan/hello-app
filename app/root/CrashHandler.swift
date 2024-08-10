import Foundation

import HelloCore

extension NSException: @unchecked Sendable {}

public enum CrashHandler {
  
  enum Signal: CaseIterable {
    case hangup
    case interrupt
    case quit
    case illegal
    case trap
    case abort
    case floatingPointError
    case kill
    case segmentationFault
    case pipeError
    case termination
    
    init?(_ int: Int32) {
      for signal in Signal.allCases {
        if int == signal.value {
          self = signal
          return
        }
      }
      return nil
    }
    
    var value: Int32 {
      switch self {
      case .hangup: return SIGHUP
      case .interrupt: return SIGINT
      case .quit: return SIGQUIT
      case .illegal: return SIGILL
      case .trap: return SIGTRAP
      case .abort: return SIGABRT
      case .floatingPointError: return SIGFPE
      case .kill: return SIGKILL
      case .segmentationFault: return SIGSEGV
      case .pipeError: return SIGPIPE
      case .termination: return SIGTERM
      }
    }
    
    var name: String {
      switch self {
      case .hangup: return "SIGHUP"
      case .interrupt: return "SIGINT"
      case .quit: return "SIGQUIT"
      case .illegal: return "SIGILL"
      case .trap: return "SIGTRAP"
      case .abort: return "SIGABRT"
      case .floatingPointError: return "SIGFPE"
      case .kill: return "SIGKILL"
      case .segmentationFault: return "SIGSEGV"
      case .pipeError: return "SIGPIPE"
      case .termination: return "SIGTERM"
      }
    }
    
    var description: String {
      switch self {
      case .hangup: return "Hangup"
      case .interrupt: return "Interrupt"
      case .quit: return "Quit"
      case .illegal: return "Illegal Instruction"
      case .trap: return "Trap"
      case .abort: return "Abort"
      case .floatingPointError: return "Floating Point Error"
      case .kill: return "Kill"
      case .segmentationFault: return "Segmentation Violation"
      case .pipeError: return "Pipe write failure"
      case .termination: return "Termination"
      }
    }
  }
  
  private static let originalExceptionHandler: (@convention(c) (NSException) -> Void)? = NSGetUncaughtExceptionHandler()
  
  private static let exceptionHandler: @convention(c) @Sendable (NSException) -> Void = { exception in
    Log.crash("Crash with \(exception.name.rawValue): \(exception.description)", context: "App")
    restore()
    Task {
      try await Log.logger.flush(force: true)
      exception.raise()
    }
  }
  
  private static let signalHandler: @convention(c) @Sendable (Int32) -> Void = { signal in
    
    //    var stack = Thread.callStackSymbols
    //    stack.removeFirst(2)
    //    let callStack = stack.joined(separator: "\r")
    //    let reason = "Signal \(CrashEye.name(of: signal))(\(signal)) was raised.\n"
    //    let appinfo = CrashEye.appInfo()
    //
    //    let model = CrashModel(type:CrashModelType.signal,
    //                           name:CrashEye.name(of: signal),
    //                           reason:reason,
    //                           appinfo:appinfo,
    //                           callStack:callStack)
    let stackTrace = Thread.callStackSymbols.reduce("") { $0 + "\n" + $1 }
    if let signal = Signal(signal) {
      Log.crash("Signal \(signal.name) (\(signal.description))\(stackTrace)")
    } else {
      Log.crash("Signal \(signal)\(stackTrace)")
    }
    restore()
    Task {
      try await Log.logger.flush(force: true)
      kill(getpid(), signal)
    }
  }
  
  public static func setup() {
    NSSetUncaughtExceptionHandler(exceptionHandler)
    for errorSignal in Signal.allCases {
      signal(errorSignal.value, signalHandler)
    }
  }
  
  private static func restore() {
    NSSetUncaughtExceptionHandler(originalExceptionHandler)
    
    for errorSignal in Signal.allCases {
      signal(errorSignal.value, SIG_DFL)
    }
  }
}
