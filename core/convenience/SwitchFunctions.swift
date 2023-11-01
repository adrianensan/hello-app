import Foundation

public func ~=<T>(block: (T) -> Bool, value: T) -> Bool {
  block(value)
}
