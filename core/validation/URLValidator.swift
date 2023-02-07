import Foundation

public enum URLValidator {
  public static func isValid(url: String) -> Bool {
    var url = url.lowercased().deletingPrefix("https://").deletingPrefix("http://")
    
    if let pathIndex = url.firstIndex(of: "/") {
      url = String(url[..<pathIndex])
    }
    
    let components = url.components(separatedBy: ".")
    guard components.count > 1,
          let tld = components.last else { return false }
    
    for domainComponent in components {
      guard !domainComponent.isEmpty
              && domainComponent.count < 64
              && CharacterSet(charactersIn: domainComponent).isSubset(of: .alphanumerics.union(.init(["-"])))
              && !domainComponent.hasPrefix("-") && !domainComponent.hasSuffix("-")
      else { return false }
    }
    
    guard CharacterSet(charactersIn: String(tld)).isSubset(of: .letters) else { return false }
    
    return true
  }
}
