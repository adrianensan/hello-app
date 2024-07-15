import Foundation

public extension String {
  static var uuid: String { UUID().uuidString }
  
  subscript(_ i: Int) -> Character {
    self[index(for: i)]
  }
  
  subscript(_ range: Range<Int>) -> Substring {
    self[index(for: range.lowerBound)..<index(for: range.upperBound)]
  }
  
  func index(for offset: Int) -> Index {
    index(startIndex, offsetBy: offset)
  }
  
  var fileSafeString: String {
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
  
  mutating func deletePrefix(_ prefix: String) {
    self = deletingPrefix(prefix)
  }
  
  func deletingSuffix(_ suffix: String) -> String {
    guard self.hasSuffix(suffix) else { return self }
    return String(dropLast(suffix.count))
  }
  
  mutating func deleteSuffix(_ suffix: String) {
    self = deletingSuffix(suffix)
  }
}

public extension StringProtocol {
  var url: URL? {
    guard self.contains(".") else { return nil }
    
    let urlString = removingHTMLEntities
    
    return URL(string: urlString)
  }
  
  var unwrappingCDATA: SubSequence {
    guard self.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("<![CDATA["),
          let cdataStartIndex = range(of: "<![CDATA[")?.upperBound,
          let cdataEndIndex = range(of: "]]>")?.lowerBound else {
      return self[...]
    }
    return self[cdataStartIndex..<cdataEndIndex]
  }
  
  var removingHTTP: String {
    var modified = String(self)
    if hasPrefix("https://") {
      modified = String(modified.dropFirst(8))
    } else if hasPrefix("http://") {
      modified = String(modified.dropFirst(7))
    }
    
    if hasPrefix("www.") {
      modified = String(modified.dropFirst(4))
    }
    
    return modified
  }
}
