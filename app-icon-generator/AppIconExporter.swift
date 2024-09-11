import SwiftUI
import UniformTypeIdentifiers

import HelloApp
import HelloCore

struct AppIconEmptyContents: Codable, Sendable {
  var info: AppIconContentsInfo = AppIconContentsInfo()
}

struct AppIconContentsInfo: Codable, Sendable {
  var author: String = "xcode"
  var version: Int = 1
}

struct LayeredAppIconLayerContents: Codable, Sendable {
  var filename: String
}

struct LayeredAppIconContents: Codable, Sendable {
  var info: AppIconContentsInfo = AppIconContentsInfo()
  var layers: [LayeredAppIconLayerContents] = []
}

enum VisionOSAppIconLayer: String, CaseIterable, Sendable {
  case front
  case middle
  case back
  
  var fileName: String {
    switch self {
    case .front: "Front.solidimagestacklayer"
    case .middle: "Middle.solidimagestacklayer"
    case .back: "Back.solidimagestacklayer"
    }
  }
}

@MainActor
public enum AppIconExporter {
  
  static var shouldTinify: Bool = false
  
  static var baseExportPath: URL? { FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.appendingPathComponent("hello-icons") }
  
  //  public func exportAllIcons<AppIcon: BaseAppIcon>(iconType: AppIcon.Type) async throws {
  //    if let iOSIcons = (iconType as? IOSAppIcon)?.allIcons {
  //      export(iOSIcons: iOSIcons)
  //    }
  //  }
  
  static public func reset() {
    guard let exportPath = baseExportPath else { return }
    try? FileManager.default.removeItem(at: exportPath)
  }
  
  static public func export<AppConfig: HelloAppConfig>(_ appConfig: AppConfig) async throws {
    if let iOSIcons = AppConfig.AppIconType.collections.flatMap { $0.icons } as? [any IOSAppIcon], !iOSIcons.isEmpty {
      try await export(iOSIcons: iOSIcons, for: appConfig)
    } else if let iOSIcons = [AppConfig.AppIconType.defaultIcon] as? [any IOSAppIcon] {
      try await export(iOSIcons: iOSIcons, for: appConfig)
    }
    
    if let iMessageIcon = AppConfig.AppIconType.defaultIcon as? any IMessageAppIcon {
      try await export(iMessageIcon: iMessageIcon, for: appConfig)
    }
    
    if let watchOSIcon = AppConfig.AppIconType.defaultIcon as? any WatchAppIcon {
      try await export(watchOSIcon: watchOSIcon, for: appConfig)
    }
    
    if let visionOSIcons = AppConfig.AppIconType.collections.flatMap { $0.icons } as? [any VisionOSAppIcon], !visionOSIcons.isEmpty {
      try await export(visionOSIcons: visionOSIcons, for: appConfig)
    } else if let visionOSIcons = [AppConfig.AppIconType.defaultIcon] as? [any VisionOSAppIcon] {
      try await export(visionOSIcons: visionOSIcons, for: appConfig)
    }
    
    if let macOSIcons = AppConfig.AppIconType.collections.flatMap { $0.icons } as? [any MacOSAppIcon], !macOSIcons.isEmpty {
      try await export(macOSIcons: macOSIcons, for: appConfig)
    } else if let macOSIcons = [AppConfig.AppIconType.defaultIcon] as? [any MacOSAppIcon] {
      try await export(macOSIcons: macOSIcons, for: appConfig)
    }
  }
  
  static private func export<AppConfig: HelloAppConfig>(iOSIcons: [any IOSAppIcon], for appConfig: AppConfig) async throws {
    guard let baseExportPath = baseExportPath else { return }
    let shouldExportThumbnails = iOSIcons.count > 1
    let exportPath = baseExportPath.appendingPathComponent("\(appConfig.id)/ios")
    let thumbnailExportPath = baseExportPath.appendingPathComponent("\(appConfig.id)/ios-thumbnails")
    try? FileManager.default.createDirectory(at: exportPath, withIntermediateDirectories: true, attributes: [:])
    if shouldExportThumbnails {
      try? FileManager.default.createDirectory(at: thumbnailExportPath, withIntermediateDirectories: true, attributes: [:])
    }
    
    for icon in iOSIcons {
      let iconExportPath = exportPath.appendingPathComponent("\(icon.imageName).appiconset")
      try? FileManager.default.createDirectory(at: iconExportPath, withIntermediateDirectories: true, attributes: [:])
      
      let lightIconImageData = try await imageData(for: icon.iOSView.light.flattenedView, size: CGSize(width: 1024, height: 1024), allowOpacity: false)
      try lightIconImageData.write(to: iconExportPath.appendingPathComponent(AppIconAssetsContents.iOSFileName(appIconName: icon.imageName, suffix: "")))
      
      if let darkIcon = icon.iOSView.dark, let tintableIcon = icon.iOSView.tintable {
        try await save(view: darkIcon.flattenedView, size: CGSize(width: 1024, height: 1024),
                       to: iconExportPath.appendingPathComponent(AppIconAssetsContents.iOSFileName(appIconName: icon.imageName, suffix: "-dark")),
                       allowOpacity: true)
        try await save(view: tintableIcon.flattenedView, size: CGSize(width: 1024, height: 1024),
                       to: iconExportPath.appendingPathComponent(AppIconAssetsContents.iOSFileName(appIconName: icon.imageName, suffix: "-tintable")),
                       allowOpacity: false)
        try AppIconAssetsContents.iOS(name: icon.imageName)
          .prettyJSONData
          .write(to: iconExportPath.appendingPathComponent("Contents.json"))
      } else {
        try AppIconAssetsContents.iOSClassic(name: icon.imageName)
          .prettyJSONData
          .write(to: iconExportPath.appendingPathComponent("Contents.json"))
      }
      
      let thumbnailImageData = try await ImageProcessor.resize(imageData: lightIconImageData, maxSize: 180, format: .png)
      if shouldExportThumbnails {
        try thumbnailImageData.write(to: thumbnailExportPath.appendingPathComponent(AppIconAssetsContents.iOSFileName(appIconName: icon.imageName, suffix: "")))
      }
      if icon.id == AppConfig.AppIconType.defaultIcon.id {
        let sharedExportPath = baseExportPath.appendingPathComponent("hello")
        try? FileManager.default.createDirectory(at: sharedExportPath, withIntermediateDirectories: true, attributes: [:])
        try thumbnailImageData.write(to: sharedExportPath.appendingPathComponent(AppIconAssetsContents.iOSFileName(appIconName: appConfig.id, suffix: "-ios")))
      }
    }
  }
  
  static private func export<AppConfig: HelloAppConfig>(iMessageIcon icon: some IMessageAppIcon, for appConfig: AppConfig) async throws {
    guard let baseExportPath else { return }
    let iconExportPath = baseExportPath.appendingPathComponent("\(appConfig.id)/imessage/\(icon.imageName).stickersiconset")
    try? FileManager.default.createDirectory(at: iconExportPath, withIntermediateDirectories: true, attributes: [:])
    
    let squareImageData = try await imageData(for: icon.iMessageView.flattenedView, size: CGSize(width: 1024, height: 1024), allowOpacity: false)
    let imessageImageData = try await imageData(for: icon.iMessageView.flattenedView, size: CGSize(width: 1024, height: 768), allowOpacity: false)
    
    for scale in IconScale.iMessageIconScales {
      let resizedImageData = try await ImageProcessor.resize(
        imageData: scale.size.isSquare ? squareImageData : imessageImageData,
        maxSize: Int(scale.size.maxDimension) * scale.scaleFactor,
        format: .png)
      try resizedImageData.write(to: iconExportPath.appendingPathComponent(AppiconsetContentsGenerator.fileName(appIconName: icon.imageName, scale: scale)))
      try AppiconsetContentsGenerator.contentsFile(for: icon.imageName, with: IconScale.iMessageIconScales)
        .write(to: iconExportPath.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
    }
    
    let thumbnailImageData = try await ImageProcessor.resize(imageData: imessageImageData, maxSize: 180, format: .png)
    let sharedExportPath = baseExportPath.appendingPathComponent("hello")
    try? FileManager.default.createDirectory(at: sharedExportPath, withIntermediateDirectories: true, attributes: [:])
    try thumbnailImageData.write(to: sharedExportPath.appendingPathComponent(AppIconAssetsContents.iOSFileName(appIconName: appConfig.id, suffix: "-imessage")))
  }
  
  static private func export<AppConfig: HelloAppConfig>(watchOSIcon icon: some WatchAppIcon, for appConfig: AppConfig) async throws {
    guard let baseExportPath else { return }
    let iconExportPath = baseExportPath.appendingPathComponent("\(appConfig.id)/imessage/\(icon.imageName).stickersiconset")
    try? FileManager.default.createDirectory(at: iconExportPath, withIntermediateDirectories: true, attributes: [:])
    
    let imageData = try await imageData(for: icon.watchOSView.flattenedView, size: CGSize(width: 1024, height: 1024), allowOpacity: false)
    
    for scale in IconScale.watchOSIconScales {
      let resizedImageData = try await ImageProcessor.resize(
        imageData: imageData,
        maxSize: Int(scale.size.maxDimension) * scale.scaleFactor,
        format: .png)
      try resizedImageData.write(to: iconExportPath.appendingPathComponent(AppiconsetContentsGenerator.fileName(appIconName: icon.imageName, scale: scale)))
      try AppiconsetContentsGenerator.contentsFile(for: icon.imageName, with: IconScale.iMessageIconScales)
        .write(to: iconExportPath.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
    }
    
    let thumbnailImageData = try await ImageProcessor.resize(imageData: imageData, maxSize: 120, format: .png)
    let sharedExportPath = baseExportPath.appendingPathComponent("hello")
    try? FileManager.default.createDirectory(at: sharedExportPath, withIntermediateDirectories: true, attributes: [:])
    try thumbnailImageData.write(to: sharedExportPath.appendingPathComponent(AppIconAssetsContents.iOSFileName(appIconName: appConfig.id, suffix: "-watchos")))
  }
  
  static public func export<AppConfig: HelloAppConfig>(visionOSIcons icons: [any VisionOSAppIcon], for appConfig: AppConfig) async throws {
    guard let baseExportPath else { return }
    let shouldExportThumbnails = icons.count > 1
    let exportPath = baseExportPath.appendingPathComponent("\(appConfig.id)/visionos")
    let thumbnailExportPath = baseExportPath.appendingPathComponent("\(appConfig.id)/visionos-thumbnails")
    try? FileManager.default.createDirectory(at: exportPath, withIntermediateDirectories: true, attributes: [:])
    if shouldExportThumbnails {
      try? FileManager.default.createDirectory(at: thumbnailExportPath, withIntermediateDirectories: true, attributes: [:])
    }
    
    for icon in icons {
      let iconExportPath = exportPath.appendingPathComponent("\(icon.imageName).solidimagestack")
      try? FileManager.default.createDirectory(at: iconExportPath, withIntermediateDirectories: true, attributes: [:])
      var layerContents = LayeredAppIconContents()
      let scale = IconScale(size: 512, scaleFactor: 2, purpose: .vision)
      for (i, layer) in icon.visionOSView.layers.enumerated() {
        let layerName = "layer\(i)"
        let layerFilename = "\(layerName).solidimagestacklayer"
        let iconLayerURL = iconExportPath.appendingPathComponent(layerFilename)
        let iconLayerInnerContentsURL = iconLayerURL.appendingPathComponent("Content.imageset")
        layerContents.layers.append(LayeredAppIconLayerContents(filename: layerFilename))
        try? FileManager.default.createDirectory(at: iconLayerInnerContentsURL, withIntermediateDirectories: true, attributes: [:])
        try AppIconEmptyContents().jsonData.write(to: iconLayerURL.appendingPathComponent("Contents.json"))
        
        let imageLayerName = "\(icon.imageName)-\(layerName)"
        try await save(view: layer, size: scale.size * CGFloat(scale.scaleFactor),
                       to: iconLayerInnerContentsURL.appendingPathComponent(AppiconsetContentsGenerator.fileName(appIconName: imageLayerName, scale: scale)),
                       allowOpacity: i != icon.visionOSView.layers.count - 1)
        try AppiconsetContentsGenerator.contentsFile(for: imageLayerName, with: [scale])
          .write(to: iconLayerInnerContentsURL.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
      }
      try? layerContents.jsonData.write(to: iconExportPath.appendingPathComponent("Contents.json"))
      
      let imageData = try await imageData(for: icon.visionOSView.flattenedView, size: CGSize(width: 1024, height: 1024), allowOpacity: false)
      let thumbnailImageData = try await ImageProcessor.resize(imageData: imageData, maxSize: 180, format: .png)
      if shouldExportThumbnails {
        try thumbnailImageData.write(to: thumbnailExportPath.appendingPathComponent(AppIconAssetsContents.iOSFileName(appIconName: icon.imageName, suffix: "")))
      }
      if icon.id == AppConfig.AppIconType.defaultIcon.id {
        let sharedExportPath = baseExportPath.appendingPathComponent("hello")
        try? FileManager.default.createDirectory(at: sharedExportPath, withIntermediateDirectories: true, attributes: [:])
        try thumbnailImageData.write(to: sharedExportPath.appendingPathComponent(AppIconAssetsContents.iOSFileName(appIconName: appConfig.id, suffix: "-visionos")))
      }
    }
  }
  
  static public func export<AppConfig: HelloAppConfig>(macOSIcons icons: [any MacOSAppIcon], for appConfig: AppConfig) async throws {
    guard let baseExportPath else { return }
    let exportPath = baseExportPath.appendingPathComponent("\(appConfig.id)/macos")
    
    // Main App Icon
    let mainIconExportPath = exportPath.appendingPathComponent("AppIcon.appiconset")
    try? FileManager.default.createDirectory(at: mainIconExportPath, withIntermediateDirectories: true, attributes: [:])
    
    // Main App Icon
    guard let mainIcon = icons.first(where: { $0.id == AppConfig.AppIconType.defaultIcon.id }) else {
      throw HelloError("No main macOS icon")
    }
    let imageData = try await imageData(
      for: mainIcon.macOSView.view.flattenedView,
      size: CGSize(width: 1024, height: 1024),
      allowOpacity: true)
    
    for scale in IconScale.macOSMainIconScales {
      let resizedImageData = try await ImageProcessor.resize(imageData: imageData, maxSize: Int(scale.size.maxDimension) * scale.scaleFactor, format: .png)
      try resizedImageData.write(to: mainIconExportPath.appendingPathComponent(AppiconsetContentsGenerator.fileName(appIconName: AppConfig.AppIconType.defaultIcon.imageName, scale: scale)))
      
      if scale.size.maxDimension == 256 && scale.scaleFactor == 1 {
        let sharedExportPath = baseExportPath.appendingPathComponent("hello")
        try? FileManager.default.createDirectory(at: sharedExportPath, withIntermediateDirectories: true, attributes: [:])
        try resizedImageData.write(to: sharedExportPath.appendingPathComponent(AppIconAssetsContents.iOSFileName(appIconName: appConfig.id, suffix: "-macos")))
      }
    }
    try? AppiconsetContentsGenerator.contentsFile(for: AppConfig.AppIconType.defaultIcon.imageName, with: IconScale.macOSMainIconScales)
      .write(to: mainIconExportPath.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
      
    
    for icon in icons {
      try? FileManager.default.createDirectory(at: exportPath, withIntermediateDirectories: true, attributes: [:])
      
      try await save(view: icon.macOSView.view.flattenedView,
                     size: CGSize(width: 256, height: 256),
                     to: exportPath.appendingPathComponent("\(icon.imageName).png"),
                     allowOpacity: true)
    }
  }
  
  enum AppIconCreateError: Error {
    case failedToRender
    case failedGetData
  }
  
  @MainActor
  static func save(view: some View, size: CGSize, to path: URL, allowOpacity: Bool) async throws {
    let data = try await imageData(for: view, size: size, allowOpacity: allowOpacity)
    try data.write(to: path)
  }
  
  @MainActor
  static func imageData(for view: some View, size: CGSize, allowOpacity: Bool) async throws -> Data {
    let imageRender = ImageRenderer(content: view.frame(CGSize(width: size.width, height: size.height)))
    
    //    let imageRender = ImageRenderer(content: view
    //      .frame(CGSize(width: 1024 * min(1, size.width / size.height),
    //                    height: 1024 * min(1, size.height / size.width))))
    imageRender.isOpaque = !allowOpacity
    //    imageRender.proposedSize = size
    guard let cgImage = imageRender.cgImage else { throw AppIconCreateError.failedToRender }
    let nsData = NSMutableData()
    let downsampleOptions = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceShouldCacheImmediately: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageDestinationLossyCompressionQuality: 0.9,
    ] as [NSObject: AnyObject] as [AnyHashable: Any] as CFDictionary
    
    guard let destination = CGImageDestinationCreateWithData(nsData, UTType.png.identifier as CFString, 1, downsampleOptions) else { throw AppIconCreateError.failedGetData }
    CGImageDestinationAddImage(destination, cgImage, downsampleOptions)
    guard CGImageDestinationFinalize(destination) else { throw AppIconCreateError.failedGetData }
    var data = nsData as Data
    //    if size.maxSide < 1024 {
    //      data = try await ImageProcessor.resize(imageData: data, maxSize: Int(size.maxSide), format: .png)
    //    }
    if shouldTinify {
      //      data = DefaultHelloAPIClient.main.request(endpoint: .)
    }
    return data
  }
}
