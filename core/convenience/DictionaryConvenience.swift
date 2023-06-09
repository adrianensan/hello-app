import Foundation

public extension Dictionary {
  var valuesArray: [Value] {
    Array(self.values)
  }
}
