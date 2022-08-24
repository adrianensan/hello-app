import Foundation

public struct IconScale: Equatable {
  
  public enum Purpose: String {
    case iphone, ipad, mac, watch, universal
    case iosMarketing = "ios-marketing"
    case watchMarketing = "watch-marketing"
  }
  
  public enum Role: String {
    case appLauncher
    case quickLook
    case notificationCenter
    case companionSettings
  }
  
  public enum SubType: String {
    case watch38mm = "38mm"
    case watch40mm = "40mm"
    case watch41mm = "41mm"
    case watch42mm = "42mm"
    case watch44mm = "44mm"
    case watch45mm = "45mm"
  }
  
  public enum Platform: String {
    case ios
  }
  
  public var size: CGSize
  public var scaleFactor: Int
  public var purpose: Purpose
  public var role: Role?
  public var platform: Platform?
  public var subtype: SubType?
  
  public init(size: Double,
              scaleFactor: Int,
              purpose: Purpose,
              role: Role? = nil,
              platform: Platform? = nil,
              subtype: SubType? = nil) {
    self.size = CGSize(width: size, height: size)
    self.scaleFactor = scaleFactor
    self.purpose = purpose
    self.role = role
    self.platform = platform
    self.subtype = subtype
  }
  
  public init(size: CGSize,
              scaleFactor: Int,
              purpose: Purpose,
              role: Role? = nil,
              platform: Platform? = nil,
              subtype: SubType? = nil) {
    self.size = size
    self.scaleFactor = scaleFactor
    self.purpose = purpose
    self.role = role
    self.platform = platform
    self.subtype = subtype
  }
  
  var widthScale: CGFloat {
    min(1, size.width / size.height)
  }
  
  var heightScale: CGFloat {
    min(1, size.height / size.width)
  }
}
