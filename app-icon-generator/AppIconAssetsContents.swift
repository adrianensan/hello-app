import Foundation

public struct AppIconAssetsContents: Codable, Sendable {
  
  static func iOSFileName(appIconName: String, suffix: String) -> String {
    "\(appIconName)\(suffix).png"
  }
    
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
    public var platform: String
    public var idiom: String
    public var scale: String?
    public var size: String
    public var appearances: [Appearance]?
    
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
}

public extension AppIconAssetsContents {
  static func iOSClassic(name: String) -> AppIconAssetsContents {
    AppIconAssetsContents(images: [
      .iOS(fileName: AppIconAssetsContents.iOSFileName(appIconName: name, suffix: ""))
    ])
  }
  
  static func iOS(name: String) -> AppIconAssetsContents {
    AppIconAssetsContents(images: [
      .iOS(fileName: AppIconAssetsContents.iOSFileName(appIconName: name, suffix: "")),
      .iOS(fileName: AppIconAssetsContents.iOSFileName(appIconName: name, suffix: "-dark"), variant: .dark),
      .iOS(fileName: AppIconAssetsContents.iOSFileName(appIconName: name, suffix: "-tintable"), variant: .tinted)
    ])
  }
  
  static func watchOS(fileName: String) -> AppIconAssetsContents {
    AppIconAssetsContents(images: [.watchOS(fileName: fileName)])
  }
}

public extension AppIconAssetsContents.Image {
  static func iOS(fileName: String, variant: Appearance? = nil) -> AppIconAssetsContents.Image {
    .init(filename: fileName, platform: "ios", appearances: variant.map { [$0] })
  }
  
  static func watchOS(fileName: String) -> AppIconAssetsContents.Image {
    .init(filename: fileName, platform: "watchos")
  }
}

public struct AssetsContents: Codable, Sendable {
  public var author: String = "hello"
  public var version: Int = 1
}
