import Foundation
#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

public enum OSInfo {
  
  public static var version: String {
    let version = ProcessInfo.processInfo.operatingSystemVersion
    return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
  }
  
#if os(watchOS)
  public static let platform: String = "watchOS"
#elseif os(macOS)
  public static let platform: String = "macOS"
#elseif os(iOS)
  public static let platform: String = "iOS"//UIDevice.current.systemName
#else
  public static let platform: String = "Linux"
#endif
  
  public static let description: String = "\(platform) \(version)"
}
