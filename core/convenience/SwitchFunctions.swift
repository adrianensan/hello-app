import Foundation

public func hasPrefix(_ prefix: String) -> (String) -> Bool {
  { value in value.hasPrefix(prefix) }
}

public func ~=<T>(block: (T) -> Bool, value: T) -> Bool {
  block(value)
}
