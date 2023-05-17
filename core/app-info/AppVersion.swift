import Foundation

public struct AppVersion: LosslessStringConvertible, Codable, Equatable, Comparable, Hashable, Sendable {
  
  public static var current: AppVersion? {
    guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"],
          let build = Bundle.main.infoDictionary?["CFBundleVersion"] else { return nil }
    return AppVersion("\(version).\(build)")
  }
  
  public static func <(lhs: AppVersion, rhs: AppVersion) -> Bool {
    if lhs.major != rhs.major {
      return lhs.major < rhs.major
    } else if lhs.minor != rhs.minor {
      return lhs.minor < rhs.minor
    } else if lhs.patch != rhs.patch {
      return lhs.patch < rhs.patch
    } else {
      return lhs.build < rhs.build
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
  
  public init?(_ versionString: String) {
    let components = versionString.split(separator: ".")
    guard components.count == 3 || components.count == 4,
          let major = Int(components[0]),
          let minor = Int(components[1])
    else { return nil }
    
    self.major = major
    self.minor = minor
    if components.count == 4 {
      guard let patch = Int(components[2]),
            let build = Int(components[3])
      else { return nil }
      self.patch = patch
      self.build = build
    } else {
      if components[2].starts(with: "10") && components[2].count > 2 {
        guard let build = Int(components[2].dropFirst(2)) else { return nil }
        self.patch = 10
        self.build = build
      } else if components[2].count > 1 {
        guard let patch = Int(components[2].prefix(1)),
              let build = Int(components[2].dropFirst(1)) else { return nil }
        self.patch = patch
        self.build = build
      } else {
        guard let patch = Int(components[2].prefix(1)) else { return nil }
        self.patch = patch
        self.build = 0
      }
    }
  }
  
  public var description: String { "\(major).\(minor).\(patch).\(build)" }
  
  public var display: String { "\(major).\(minor).\(patch) (\(build))" }
  
  var intValue: Int {
    major * 10000000 + minor * 100000 + patch * 1000 + build
  }
}
