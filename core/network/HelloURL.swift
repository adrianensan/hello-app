import Foundation

public struct HelloURL: Codable, Sendable {
  
  public var scheme: String
  public var host: String
  public var path: String
  
  public init?(string: String) {
    let trimmedString: String
    if string.hasPrefix("https://") {
      scheme = "https"
      trimmedString = string.deletingPrefix("https://")
    } else if string.hasPrefix("http://") {
      scheme = "http"
      trimmedString = string.deletingPrefix("http://")
    } else {
      scheme = "https"
      trimmedString = string
    }
    let pathSplit = trimmedString.split(separator: "/", maxSplits: 1, omittingEmptySubsequences: false)
    if pathSplit.count > 1 {
      host = String(pathSplit[0])
      path = "/" + String(pathSplit[1])
    } else {
      host = trimmedString
      path = ""
    }
  }
  
  public var url: String {
    "\(scheme)://\(host)\(path)"
  }
  
  public var rootURL: String {
    "\(scheme)://\(host)"
  }
  
  public var httpsURL: String {
    "https://\(host)\(path)"
  }
}
