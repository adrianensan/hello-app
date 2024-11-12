import Foundation

import HelloCore
import HelloApp

public struct AppIconImageVariant: Sendable {
  
  public enum Appearance: String, Sendable {
    case dark
    case tinted
  }
  
  public enum Platform: String, Sendable {
    case ios
    case watchos
  }
  
  public enum Idiom: String, Sendable {
    case universal
    case iphone
    case ipad
    case iosMarketing = "ios-marketing"
    case mac
    case vision
  }
  
  public var platform: Platform?
  public var idiom: Idiom
  public var scale: Int?
  public var size: CGSize
  public var appearance: Appearance?
  
  public init(platform: Platform? = nil,
              idiom: Idiom = .universal,
              scale: Int? = nil,
              size: CGSize,
              appearance: Appearance? = nil) {
    self.platform = platform
    self.idiom = idiom
    self.scale = scale
    self.size = size
    self.appearance = appearance
  }
  
  public init(platform: Platform? = nil,
              idiom: Idiom = .universal,
              scale: Int? = nil,
              size: CGFloat,
              appearance: Appearance? = nil) {
    self.init(platform: platform, idiom: idiom, scale: scale, size: CGSize(width: size, height: size), appearance: appearance)
  }
  
  var sizeString: String { "\(size.width.string)x\(size.height.string)" }
  
  func imageName(for appIconName: String, suffix: String = "", format: HelloImageFormat = .png) -> String {
    let appearanceSuffix: String = appearance.map { "-" + $0.rawValue } ?? ""
    return if let scale {
      "\(appIconName)\(appearanceSuffix)\(suffix)-\(sizeString)@\(scale)x.\(format.fileExtension)"
    } else {
      "\(appIconName)\(appearanceSuffix)\(suffix).\(format.fileExtension)"
    }
  }
  
//  func imageName(for icon: some BaseAppIcon, suffix: String = "", format: HelloImageFormat = .png) -> String {
//    imageName(for: icon.imageName, suffix: suffix, format: format)
//  }
  
  func imageName(for icon: any HelloAppIcon, suffix: String = "", format: HelloImageFormat = .png) -> String {
    imageName(for: icon.systemName, suffix: suffix, format: format)
  }
}
