import Foundation

public func valueTransition<Value: HelloNumeric>(from initialValue: Value, to targetValue: Value, progress: Value) -> Value {
  initialValue + progress * (targetValue - initialValue)
}
