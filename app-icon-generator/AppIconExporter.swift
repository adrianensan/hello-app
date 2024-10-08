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
  
  enum AppIconCreateError: Error {
    case failedToRender
    case failedGetData
  }
  
  public static var shouldTinify: Bool = false
  
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
  
  static public func export(for appConfig: some HelloAppConfig) async throws {
    for platform in appConfig.appIconConfig.platforms {
      guard let appIconConfig = appConfig.appIconConfig as? any HelloAppIconGeneratorConfig else {
        fatalError("no HelloAppIconGeneratorConfig")
      }
      switch platform {
      case .iOS:
        try await export(
          iOSIcons: appIconConfig.allGenaratable,
          for: appIconConfig,
          context: AppIconExporterContext(
            appID: appConfig.id,
            platform: .iOS,
            size: CGSize(width: 1024, height: 1024),
            iconFill: appIconConfig.iconFill,
            iconStroke: appIconConfig.iconStroke))
      case .iMessage:
        try await export(
          iMessageIcon: appIconConfig.defaultGeneratable,
          for: appIconConfig,
          context: AppIconExporterContext(
            appID: appConfig.id,
            platform: .iMessage,
            size: CGSize(width: 1024, height: 768),
            iconFill: appIconConfig.iconFill,
            iconStroke: appIconConfig.iconStroke))
      case .watchOS:
        try await export(
          watchOSIcon: appIconConfig.defaultGeneratable,
          for: appIconConfig,
          context: AppIconExporterContext(
            appID: appConfig.id,
            platform: .watchOS,
            size: CGSize(width: 1024, height: 1024),
            iconFill: appIconConfig.iconFill,
            iconStroke: appIconConfig.iconStroke))
      case .visionOS:
        try await export(
          visionOSIcon: appIconConfig.defaultGeneratable,
          for: appIconConfig,
          context: AppIconExporterContext(
            appID: appConfig.id,
            platform: .visionOS,
            size: CGSize(width: 1024, height: 1024),
            iconFill: appIconConfig.iconFill,
            iconStroke: appIconConfig.iconStroke))
      case .macOS:
        try await export(
          macOSIcons: appIconConfig.allGenaratable,
          for: appIconConfig,
          context: AppIconExporterContext(
            appID: appConfig.id,
            platform: .macOS,
            size: CGSize(width: 1024, height: 1024),
            iconFill: appIconConfig.iconFill,
            iconStroke: appIconConfig.iconStroke))
      }
    }
  }
  
  static private func export(iOSIcons: [any HelloSwiftUIAppIcon], for appConfig: some HelloAppIconGeneratorConfig, context: AppIconExporterContext) async throws {
    guard let baseExportPath = baseExportPath else { return }
    let exportPath = baseExportPath.appendingPathComponent("\(context.appID)/ios")
    let thumbnailExportPath = baseExportPath.appendingPathComponent("\(context.appID)/ios-thumbnails")
    
    try? FileManager.default.createDirectory(at: exportPath, withIntermediateDirectories: true, attributes: [:])
    try? FileManager.default.createDirectory(at: thumbnailExportPath, withIntermediateDirectories: true, attributes: [:])
    
    for icon in iOSIcons {
      let iconExportPath = exportPath.appendingPathComponent("\(icon.systemName).appiconset")
      try? FileManager.default.createDirectory(at: iconExportPath, withIntermediateDirectories: true, attributes: [:])
      
      let lightIconImageData = try await imageData(for: icon.iosView(context: context.with(size: CGSize(width: 1024, height: 1024))).light.flattenedView,
                                                   size: CGSize(width: 1024, height: 1024),
                                                   allowOpacity: false)
      
      let thumbnailImageData = try await ImageProcessor.resize(imageData: lightIconImageData, maxSize: 180, format: .heic)
      try thumbnailImageData.write(to: thumbnailExportPath.appendingPathComponent("\(icon.systemName).heic"))
      
      let isDefault = icon.id == appConfig.defaultIcon.id
      if isDefault {
        try await saveSharedThumbnail(imageData: lightIconImageData, context: context)
        try await save(imageData: lightIconImageData, icon: icon, for: .iOSMain, at: iconExportPath)
      } else {
        try await save(imageData: lightIconImageData, icon: icon, for: AppIconImageVariant.iOSAlternate, at: iconExportPath)
      }
      if let darkIcon = icon.iosView(context: context).dark, let tintableIcon = icon.iosView(context: context).tintable {
        let darkImageData = try await imageData(for: darkIcon.flattenedView, size: CGSize(width: 1024, height: 1024), allowOpacity: true, format: .png)
        for variant in (isDefault ? [.iOSDarkAppearance] : AppIconImageVariant.iOSAlternateDarkAppearance) {
          try await save(imageData: darkImageData, icon: icon, for: variant, at: iconExportPath)
        }
        
        let tintableImageData = try await imageData(for: tintableIcon.flattenedView, size: CGSize(width: 1024, height: 1024), allowOpacity: false, format: .png)
        for variant in (isDefault ? [.iOSTintedAppearance] : AppIconImageVariant.iOSAlternateTintedAppearance) {
          try await save(imageData: tintableImageData, icon: icon, for: variant, at: iconExportPath)
        }
        try generateContentsFile(at: iconExportPath, for: icon, variants: isDefault ? AppIconImageVariant.iOS : AppIconImageVariant.iOSAlternateAppearances)
      } else {
        try generateContentsFile(at: iconExportPath, for: icon, variants: isDefault ? AppIconImageVariant.iOSClassic : AppIconImageVariant.iOSAlternate)
      }
    }
  }
  
//  static public func export<AppConfig: HelloAppConfig>(_ appConfig: AppConfig) async throws {
//    if let iOSIcons = AppConfig.AppIconType.collections.flatMap { $0.icons } as? [any IOSAppIcon], !iOSIcons.isEmpty {
//      try await export(iOSIcons: iOSIcons, for: appConfig)
//    } else if let iOSIcons = [AppConfig.AppIconType.defaultIcon] as? [any IOSAppIcon] {
//      try await export(iOSIcons: iOSIcons, for: appConfig)
//    }
//    
//    if let iMessageIcon = AppConfig.AppIconType.defaultIcon as? any IMessageAppIcon {
//      try await export(iMessageIcon: iMessageIcon, for: appConfig)
//    }
//    
//    if let watchOSIcon = AppConfig.AppIconType.defaultIcon as? any WatchAppIcon {
//      try await export(watchOSIcon: watchOSIcon, for: appConfig)
//    }
//    
//    if let visionOSIcons = AppConfig.AppIconType.collections.flatMap { $0.icons } as? [any VisionOSAppIcon], !visionOSIcons.isEmpty {
//      try await export(visionOSIcons: visionOSIcons, for: appConfig)
//    } else if let visionOSIcons = [AppConfig.AppIconType.defaultIcon] as? [any VisionOSAppIcon] {
//      try await export(visionOSIcons: visionOSIcons, for: appConfig)
//    }
//    
//    if let macOSIcons = AppConfig.AppIconType.collections.flatMap { $0.icons } as? [any MacOSAppIcon], !macOSIcons.isEmpty {
//      try await export(macOSIcons: macOSIcons, for: appConfig)
//    } else if let macOSIcons = [AppConfig.AppIconType.defaultIcon] as? [any MacOSAppIcon] {
//      try await export(macOSIcons: macOSIcons, for: appConfig)
//    }
//  }
  
  static private func saveSharedThumbnail(imageData: Data, context: AppIconExporterContext) async throws {
    guard let baseExportPath else { return }
    let thumbnailImageData = try await ImageProcessor.resize(imageData: imageData, maxSize: 180, format: .png)
    let sharedExportPath = baseExportPath.appendingPathComponent("hello")
    try? FileManager.default.createDirectory(at: sharedExportPath, withIntermediateDirectories: true, attributes: [:])
    try thumbnailImageData.write(to: sharedExportPath.appendingPathComponent("\(context.appID)-\(context.platform.id).png"))
  }
  
  static private func export(iMessageIcon icon: any HelloSwiftUIAppIcon, for appConfig: some HelloAppIconGeneratorConfig, context: AppIconExporterContext) async throws {
    guard let baseExportPath else { return }
    let iconExportPath = baseExportPath.appendingPathComponent("\(context.appID)/imessage/\(icon.systemName).stickersiconset")
    try? FileManager.default.createDirectory(at: iconExportPath, withIntermediateDirectories: true, attributes: [:])
    
    let baseSquareImageData = try await imageData(for: icon.imessageView(context: context).flattenedView, size: CGSize(width: 1024, height: 1024), allowOpacity: false)
    let baseIMessageImageData = try await imageData(for: icon.imessageView(context: context.with(size: CGSize(width: 1024, height: 768))).flattenedView, size: CGSize(width: 1024, height: 768), allowOpacity: false)
    let baseSquashedIMessageImageData = try await imageData(for: icon.imessageView(context: context.with(size: CGSize(width: 1024, height: 765))).flattenedView, size: CGSize(width: 1024, height: 765), allowOpacity: false)
    
    for variant in AppIconImageVariant.iMessageVariants {
      var imageData: Data
      if variant.size.width == 27 && variant.scale == 3 || variant.size.width == 74 && variant.scale == 2 {
        imageData = baseSquashedIMessageImageData
      } else {
        imageData = variant.size.isSquare ? baseSquareImageData : baseIMessageImageData
      }
      try await save(imageData: imageData, icon: icon, for: variant, at: iconExportPath)
    }
    try generateContentsFile(at: iconExportPath, for: icon, variants: AppIconImageVariant.iMessageVariants)
    try await saveSharedThumbnail(imageData: baseIMessageImageData, context: context)
  }
  
  static private func export(watchOSIcon icon: any HelloSwiftUIAppIcon, for appConfig: some HelloAppIconGeneratorConfig, context: AppIconExporterContext) async throws {
    guard let baseExportPath else { return }
    let iconExportPath = baseExportPath.appendingPathComponent("\(context.appID)/imessage/\(icon.systemName).stickersiconset")
    try? FileManager.default.createDirectory(at: iconExportPath, withIntermediateDirectories: true, attributes: [:])
    
    let imageData = try await imageData(for: icon.watchosView(context: context).flattenedView, size: CGSize(width: 1024, height: 1024), allowOpacity: false)
    try await save(imageData: imageData, icon: icon, for: .watchOS, at: iconExportPath)
    try generateContentsFile(at: iconExportPath, for: icon, variants: [.watchOS])
    
    try await saveSharedThumbnail(imageData: imageData, context: context)
  }
  
  static public func export(visionOSIcon icon: any HelloSwiftUIAppIcon, for appConfig: some HelloAppIconGeneratorConfig, context: AppIconExporterContext) async throws {
    guard let baseExportPath else { return }
    let exportPath = baseExportPath.appendingPathComponent("\(context.appID)/visionos")
    let thumbnailExportPath = baseExportPath.appendingPathComponent("\(context.appID)/visionos-thumbnails")
    try? FileManager.default.createDirectory(at: exportPath, withIntermediateDirectories: true, attributes: [:])
    
    let iconExportPath = exportPath.appendingPathComponent("\(icon.systemName).solidimagestack")
    try? FileManager.default.createDirectory(at: iconExportPath, withIntermediateDirectories: true, attributes: [:])
    var layerContents = LayeredAppIconContents()
    for (i, layer) in icon.visionosView(context: context).layers.enumerated() {
      let layerName = "layer\(i)"
      let layerFilename = "\(layerName).solidimagestacklayer"
      let iconLayerURL = iconExportPath.appendingPathComponent(layerFilename)
      let iconLayerInnerContentsURL = iconLayerURL.appendingPathComponent("Content.imageset")
      layerContents.layers.append(LayeredAppIconLayerContents(filename: layerFilename))
      try? FileManager.default.createDirectory(at: iconLayerInnerContentsURL, withIntermediateDirectories: true, attributes: [:])
      try AppIconEmptyContents().jsonData.write(to: iconLayerURL.appendingPathComponent("Contents.json"))
      
      let imageData = try await imageData(for: layer, size: CGSize(width: 1024, height: 1024), allowOpacity: i != icon.visionosView(context: context).layers.count - 1)
      try await save(imageData: imageData, icon: icon, for: .visionOS, at: iconLayerInnerContentsURL)
      try generateContentsFile(at: iconLayerInnerContentsURL, for: icon, variants: [.visionOS])
    }
    try? layerContents.jsonData.write(to: iconExportPath.appendingPathComponent("Contents.json"))
    
    let imageData = try await imageData(for: icon.visionosView(context: context).flattenedView, size: CGSize(width: 1024, height: 1024), allowOpacity: false)
    try await saveSharedThumbnail(imageData: imageData, context: context)
  }

  static public func export(macOSIcons icons: [any HelloSwiftUIAppIcon], for appConfig: some HelloAppIconGeneratorConfig, context: AppIconExporterContext) async throws {
    guard let baseExportPath else { return }
    let exportPath = baseExportPath.appendingPathComponent("\(context.appID)/macos")
    
    let mainIconExportPath = exportPath.appendingPathComponent("AppIcon.appiconset")
    try? FileManager.default.createDirectory(at: mainIconExportPath, withIntermediateDirectories: true, attributes: [:])
    
    let imageData = try await imageData(
      for: appConfig.defaultGeneratable.macosView(context: context).view.flattenedView,
      size: CGSize(width: 1024, height: 1024),
      allowOpacity: true)
    try await saveSharedThumbnail(imageData: imageData, context: context)
    
    try await save(imageData: imageData, icon: appConfig.defaultGeneratable, for: AppIconImageVariant.macVariants, at: mainIconExportPath)
    try generateContentsFile(at: mainIconExportPath, for: appConfig.defaultGeneratable, variants: AppIconImageVariant.macVariants)
      
    for icon in icons {
      try await save(view: icon.macosView(context: context).view.flattenedView,
                     size: CGSize(width: 256, height: 256),
                     to: exportPath.appendingPathComponent("\(icon.systemName).png"),
                     allowOpacity: true)
    }
  }
  
  static private func generateContentsFile(at url: URL, for icon: some BaseAppIcon, variants: [AppIconImageVariant]) throws {
    try AppIconAssetsContents(appIconName: icon.imageName, variants: variants)
      .prettyJSONData
      .write(to: url.appendingPathComponent("Contents.json"))
  }
  
  static private func generateContentsFile(at url: URL, for icon: any HelloAppIcon, variants: [AppIconImageVariant]) throws {
    try AppIconAssetsContents(appIconName: icon.systemName, variants: variants)
      .prettyJSONData
      .write(to: url.appendingPathComponent("Contents.json"))
  }
  
  static private func resize(imageData: Data, for variant: AppIconImageVariant) async throws -> Data {
    try await ImageProcessor.resize(imageData: imageData, maxSize: Int(variant.size.maxSide * CGFloat(variant.scale ?? 1)), format: .png)
  }
  
  static private func save(imageData: Data, icon: some BaseAppIcon, for variant: AppIconImageVariant, at url: URL) async throws {
    let resizedImageData = try await resize(imageData: imageData, for: variant)
    if shouldTinify,
       let compressedImageURL = try? await DefaultHelloAPIClient.main.request(endpoint: .compressImage(imageData: resizedImageData)).headers["location"],
       let compressedImageData = try? await Downloader.main.download(from: compressedImageURL) {
      try compressedImageData.write(to: url.appendingPathComponent(variant.imageName(for: icon)))
    } else {
      try resizedImageData.write(to: url.appendingPathComponent(variant.imageName(for: icon)))
    }
  }
  
  static private func save(imageData: Data, icon: any HelloSwiftUIAppIcon, for variant: AppIconImageVariant, at url: URL) async throws {
    let resizedImageData = try await resize(imageData: imageData, for: variant)
    if shouldTinify,
       let compressedImageURL = try? await DefaultHelloAPIClient.main.request(endpoint: .compressImage(imageData: resizedImageData)).headers["location"],
       let compressedImageData = try? await Downloader.main.download(from: compressedImageURL) {
      try compressedImageData.write(to: url.appendingPathComponent(variant.imageName(for: icon)))
    } else {
      try resizedImageData.write(to: url.appendingPathComponent(variant.imageName(for: icon)))
    }
  }
  
  static private func save(imageData: Data, icon: some BaseAppIcon, for variants: [AppIconImageVariant], at url: URL) async throws {
    for variant in variants {
      try await save(imageData: imageData, icon: icon, for: variant, at: url)
    }
  }
  
  static private func save(imageData: Data, icon: any HelloSwiftUIAppIcon, for variants: [AppIconImageVariant], at url: URL) async throws {
    for variant in variants {
      try await save(imageData: imageData, icon: icon, for: variant, at: url)
    }
  }
  
  @MainActor
  static func save(view: some View, size: CGSize, to path: URL, allowOpacity: Bool, format: HelloImageFormat = .png) async throws {
    let data = try await imageData(for: view, size: size, allowOpacity: allowOpacity, format: format)
    try data.write(to: path)
  }
  
  @MainActor
  static func imageData(for view: some View, size: CGSize, allowOpacity: Bool, format: HelloImageFormat = .png) async throws -> Data {
    let imageRender = ImageRenderer(content: view.frame(CGSize(width: size.width, height: size.height)))
//    imageRender.proposedSize = .init(size)
    
    //    let imageRender = ImageRenderer(content: view
    //      .frame(CGSize(width: 1024 * min(1, size.width / size.height),
    //                    height: 1024 * min(1, size.height / size.width))))
    imageRender.isOpaque = !allowOpacity
    
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
