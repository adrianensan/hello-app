import Foundation

public enum InterpolationType: Sendable {
  case linear
//  case easeIn
//  case easeOut
//  case easeInOut
}

public func linearInterpolation<Value: HelloNumeric>(from initialValue: Value, to targetValue: Value, progress: Value) -> Value {
  interpolate(.linear, from: initialValue, to: targetValue, progress: progress)
}

public func interpolate<Value: HelloNumeric>(_ type: InterpolationType,
                                             from initialValue: Value,
                                             to targetValue: Value,
                                             progress: Value) -> Value {
//  let progressDouble = Double(progress)
  switch type {
  case .linear:
    initialValue + progress * (targetValue - initialValue)
//  case .easeIn:
//    initialValue + Value(sin(progressDouble * 0.5 * .pi)) * (targetValue - initialValue)
//  case .easeOut:
//    initialValue + Value(cos(progressDouble * 0.5 * .pi)) * (targetValue - initialValue)
  }
}
