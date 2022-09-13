import Foundation

public extension String {
  public var fileSafeString: String {
    var filtered = String(filter { !"/\\:".contains($0) })
    filtered = filtered.components(separatedBy: "?")[0]
    if filtered.count > 254 {
      filtered = String(filtered.dropFirst(filtered.count - 255))
    }
    return filtered
  }
  
  func deletingPrefix(_ prefix: String) -> String {
    guard self.hasPrefix(prefix) else { return self }
    return String(dropFirst(prefix.count))
  }
  
  func deletingSuffix(_ suffix: String) -> String {
    guard self.hasSuffix(suffix) else { return self }
    return String(dropLast(suffix.count))
  }
}
