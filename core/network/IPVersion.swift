import Foundation

public enum IPVersion: Codable, Equatable, Hashable {
  case ipv4
  case ipv6
  
  public static func infer(from systemProtocol: NSNumber) -> IPVersion? {
    switch systemProtocol.int32Value {
    case AF_INET: .ipv4
    case AF_INET6: .ipv6
    default: nil
    }
  }
  
  public static func infer(from int: Int) -> IPVersion? {
    switch int {
    case 4: .ipv4
    case 6: .ipv6
    default: nil
    }
  }
  
  public static func infer(fromFirstHeaderByte byte: UInt8?) -> IPVersion? {
    guard let byte = byte else { return nil }
    return switch (byte & 0xf0) >> 4 {
    case 4: .ipv4
    case 6: .ipv6
    default: nil
    }
  }
  
  public var systemProtocol: NSNumber {
    switch self {
    case .ipv4: NSNumber(value: AF_INET)
    case .ipv6: NSNumber(value: AF_INET6)
    }
  }
  
  public var name: String {
    switch self {
    case .ipv4: "IPv4"
    case .ipv6: "IPv6"
    }
  }
}
