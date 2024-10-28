import Foundation

public func logAndThrow(level: LogLevel = .error, context: @escaping @Sendable @autoclosure () -> String? = nil, _ message: String) throws -> Never {
  Log.log(level: level, context: context, message: { message })
  throw HelloError(message)
}

infix operator +& : AssignmentPrecedence
@inline(__always) public func +&<Value>(_ value: Value, _ applyBlock: (inout Value) -> Void) -> Value {
  var copy = value
  applyBlock(&copy)
  return copy
}

infix operator =& : AssignmentPrecedence
@inline(__always) public func =&<Value, OutValue>(_ value: Value, _ applyBlock: (Value) -> OutValue) -> OutValue {
  return applyBlock(value)
}

infix operator ?= : NilCoalescingPrecedence
@inline(__always) public func ?=(_ value: String?, _ applyBlock: (String) -> String) -> String {
  if let value = value {
    return applyBlock(value)
  } else {
    return ""
  }
}
