import Foundation

public struct HelloURLScheme: Equatable, Codable, Sendable, CustomStringConvertible {
  
  public var description: String { scheme }
  
  public var schemeWithDelimeter: String {
    scheme + "://"
  }
  
  public var scheme: String
  public var defaultPort: Int
  
  public init(_ scheme: String, defaultPort: Int = 0) {
    self.scheme = scheme
    self.defaultPort = defaultPort
  }
}

public extension HelloURLScheme {
  static var http: HelloURLScheme {
    HelloURLScheme("http", defaultPort: 83)
  }
  
  static var https: HelloURLScheme {
    HelloURLScheme("https", defaultPort: 443)
  }
  
  static var file: HelloURLScheme {
    HelloURLScheme("file", defaultPort: 443)
  }
  
  static var otp: HelloURLScheme {
    HelloURLScheme("otpauth", defaultPort: 443)
  }
}

public struct HelloURL: Codable, Sendable {
  
  public var scheme: HelloURLScheme
  public var host: String
  public var path: String
  public var port: Int?
  public var fragment: String?
  public var parameters: [String: String]
  
  public init(string: String) {
    var string = string.removingPercentEncoding ?? string
    if string.hasPrefix(HelloURLScheme.https.schemeWithDelimeter) {
      scheme = .https
      string.deletePrefix(HelloURLScheme.https.schemeWithDelimeter)
    } else if string.hasPrefix(HelloURLScheme.http.schemeWithDelimeter) {
      scheme = .http
      string.deletePrefix(HelloURLScheme.http.schemeWithDelimeter)
    } else if string.hasPrefix(HelloURLScheme.file.schemeWithDelimeter) {
      scheme = .file
      string.deletePrefix(HelloURLScheme.file.schemeWithDelimeter)
    } else if string.hasPrefix(HelloURLScheme.otp.schemeWithDelimeter) {
      scheme = .otp
      string.deletePrefix(HelloURLScheme.otp.schemeWithDelimeter)
    } else if string.contains("://") {
      let splits = string.split(separator: ":", maxSplits: 1)
      scheme = .init(String(splits[0]))
      string.deletePrefix("\(splits[0])://")
    } else {
      scheme = .https
    }
    
    let fragmentSplit = string.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)
    if fragmentSplit.count == 2 {
      fragment = String(fragmentSplit[1])
    }
    
    let querySplit = fragmentSplit[0].split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false)
    var parameters: [String: String] = [:]
    if querySplit.count == 2 {
      for keyValuePair in querySplit[1].split(separator: "&") {
        let keyAndValue = keyValuePair.split(separator: "=", maxSplits: 1)
        if keyAndValue.count == 2 {
          parameters[String(keyAndValue[0])] = String(keyAndValue[1])
        }
      }
    }
    self.parameters = parameters
    
    let pathSplit = querySplit[0].split(separator: "/", maxSplits: 1, omittingEmptySubsequences: false)
    if pathSplit.count == 2 {
      path = "/\(pathSplit[1])"
    } else {
      path = ""
    }
    
    let portSplit = pathSplit[0].split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
    if portSplit.count == 2,
       let parsedPort = Int(portSplit[1]) {
      port = parsedPort
    }
    
    host = String(portSplit[0])
  }
  
  public init(scheme: HelloURLScheme = .https,
              host: String,
              port: Int? = nil,
              path: String = "",
              parameters: [String: String] = [:]) {
    self.scheme = scheme
    self.host = host
    self.port = port
    self.path = path
    self.parameters = parameters
  }
  
  public var string: String {
    "\(scheme)://\(host)\(portString)\(path)\(parametersString)\(fragmentString)"
  }
  
  public var url: URL? {
    URL(string: string)
  }
  
  public var root: HelloURL {
    HelloURL(scheme: scheme, host: host, port: port)
  }
  
  private var portString: String {
    if let port, port != scheme.defaultPort {
      ":\(port)"
    } else {
      ""
    }
  }
  
  private var fragmentString: String {
    if let fragment {
      "#\(fragment)"
    } else {
      ""
    }
  }
  
  private var parametersString: String {
    var string = ""
    if !parameters.isEmpty {
      string += "?"
      for (i, (key, value)) in parameters.enumerated() {
        if i > 0 {
          string += "&"
        }
        string += "\(key)=\(value)"
      }
    }
    return string
  }
}
