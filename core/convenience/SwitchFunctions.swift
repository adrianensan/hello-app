import Foundation

public func hasPrefix(_ prefix: String) -> (String) -> Bool {
  { $0.hasPrefix(prefix) }
}

public func contains(_ substring: String) -> (String) -> Bool {
  { $0.contains(substring) }
}

public func ~=<T>(block: (T) -> Bool, value: T) -> Bool {
  block(value)
}
