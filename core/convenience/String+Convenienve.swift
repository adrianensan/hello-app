import Foundation

public extension String {
  static var uuid: String { HelloUUID().string }
  
  subscript(_ i: Int) -> Character {
    self[index(for: i)]
  }
  
  subscript(_ range: Range<Int>) -> Substring {
    self[index(for: range.lowerBound)..<index(for: range.upperBound)]
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

extension String: @retroactive Identifiable {
  public var id: String { self }
}

extension Character: @retroactive Identifiable {
  public var id: Character { self }
}

public extension StringProtocol {
  
  var data: Data { data(using: .utf8) ?? Data(utf8) }
  
  var url: URL? {
    guard self.contains(".") else { return nil }
    
    let urlString = removingHTMLEntities
    
    return URL(string: urlString)
  }
  
  var fileSafeString: String {
    var filtered = String(filter { !#"/\:%"'=?"#.contains($0) })
    if filtered.count > 250 {
      filtered = String(filtered.dropFirst(filtered.count - 251))
    }
    return filtered
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
  
  var sortableName: String {
    lowercased().deletingPrefix("the").trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  func index(for offset: Int) -> Index {
    index(startIndex, offsetBy: offset)
  }
}
