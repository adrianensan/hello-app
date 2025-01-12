import Foundation

public struct HelloVersion: LosslessStringConvertible, ExpressibleByStringInterpolation, Codable, Equatable, Comparable, Hashable, Sendable {
  
  public static func <(lhs: HelloVersion, rhs: HelloVersion) -> Bool {
    if lhs.major != rhs.major {
      lhs.major < rhs.major
    } else if lhs.minor != rhs.minor {
      lhs.minor < rhs.minor
    } else if lhs.patch != rhs.patch {
      lhs.patch < rhs.patch
    } else {
      lhs.build < rhs.build
    }
  }
  
  public var major: Int
  public var minor: Int
  public var patch: Int
  public var build: Int
  
  public init(_ major: Int, _ minor: Int, _ patch: Int, _ build: Int) {
    self.major = major
    self.minor = minor
    self.patch = patch
    self.build = build
  }
  
  public init(_ versionString: String, buildString: String) {
    let periodsToAdd = max(0, 2 - versionString.count(where: { $0 == "." }))
    self.init("\(versionString)\(String(repeating: ".", count: periodsToAdd)).\(buildString)")
  }
  
  public init(stringLiteral: String) {
    self.init(stringLiteral)
  }
  
  public init(_ versionString: String) {
    let versionComponents = versionString.split(separator: ".", omittingEmptySubsequences: false)
    if versionComponents.count >= 1, let major = Int(versionComponents[0]) {
      self.major = major
    } else {
      self.major = 0
    }
    
    if versionComponents.count >= 2, let minor = Int(versionComponents[1]) {
      self.minor = minor
    } else {
      self.minor = 0
    }
    
    if versionComponents.count >= 3, let patch = Int(versionComponents[2]) {
      self.patch = patch
    } else {
      self.patch = 0
    }
    
    if versionComponents.count >= 4, let build = Int(versionComponents[3]) {
      self.build = build
    } else {
      self.build = 0
    }
  }
  
//  public init?(_ versionString: String) {
//    let components = versionString.split(separator: ".")
//    guard components.count == 3 || components.count == 4,
//          let major = Int(components[0]),
//          let minor = Int(components[1])
//    else { return nil }
//    
//    self.major = major
//    self.minor = minor
//    if components.count == 4 {
//      guard let patch = Int(components[2]),
//            let build = Int(components[3])
//      else { return nil }
//      self.patch = patch
//      self.build = build
//    } else {
//      if components[2].starts(with: "10") && components[2].count > 2 {
//        guard let build = Int(components[2].dropFirst(2)) else { return nil }
//        self.patch = 10
//        self.build = build
//      } else if components[2].count > 1 {
//        guard let patch = Int(components[2].prefix(1)),
//              let build = Int(components[2].dropFirst(1)) else { return nil }
//        self.patch = patch
//        self.build = build
//      } else {
//        guard let patch = Int(components[2].prefix(1)) else { return nil }
//        self.patch = patch
//        self.build = 0
//      }
//    }
//  }
  
  public var description: String { "\(major).\(minor).\(patch).\(build)" }
  
  public var display: String {
    "\(major).\(minor)\(patch != 0 ? ".\(patch)" : "")\(build != 0 ? " (\(build))" : "")"
  }
  
  var intValue: Int {
    major * 10000000 + minor * 100000 + patch * 1000 + build
  }
}
