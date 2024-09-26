import Foundation

import HelloCore
import HelloApp

public struct AppIconAssetsContents: Codable, Sendable {
    
  public struct Image: Codable, Sendable {
    
    public struct Appearance: Codable, Sendable {
      
      public static var dark: Appearance { Appearance(value: "dark") }
      public static var tinted: Appearance { Appearance(value: "tinted") }
      
      public var appearance: String = "luminosity"
      public var value: String
      
      private init(value: String) {
        self.value = value
      }
    }
    
    public var filename: String
    public var platform: String?
    public var idiom: String
    public var scale: String?
    public var size: String
    public var appearances: [Appearance]?
    
    public init(appIconName: String, variant: AppIconImageVariant) {
      self.filename = variant.imageName(for: appIconName)
      self.platform = variant.platform?.rawValue
      self.idiom = variant.idiom.rawValue
      self.scale = variant.scale.map { "\($0)x" }
      self.size = "\(variant.size.width.string)x\(variant.size.height.string)"
      self.appearances = variant.appearance.map {
        switch $0 {
        case .dark: [.dark]
        case .tinted: [.tinted]
        }
      }
    }
    
    public init(filename: String,
                platform: String,
                idiom: String = "universal",
                scale: Int,
                size: CGSize,
                appearances: [Appearance]? = nil) {
      self.filename = filename
      self.platform = platform
      self.idiom = idiom
      self.scale = "\(scale)x"
      self.size = "\(size.width.string)x\(size.height.string)"
      self.appearances = appearances
    }
    
    public init(filename: String,
                platform: String,
                idiom: String = "universal",
                scale: String? = nil,
                size: String = "1024x1024",
                appearances: [Appearance]? = nil) {
      self.filename = filename
      self.platform = platform
      self.idiom = idiom
      self.scale = scale
      self.size = size
      self.appearances = appearances
    }
  }
  
  public var images: [Image]
  public var info = AssetsContents()
  
  fileprivate init(images: [Image]) {
    self.images = images
  }
  
  init(appIconName: String, variants: [AppIconImageVariant]) {
    images = variants.map { .init(appIconName: appIconName, variant: $0) }
  }
}

public struct AssetsContents: Codable, Sendable {
  public var author: String = "hello"
  public var version: Int = 1
}
