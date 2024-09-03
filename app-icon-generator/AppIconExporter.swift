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
public class AppIconExporter {
  
  let appName: String
  
  public init(appName: String) {
    self.appName = appName
    if let baseExportPath {
      try? FileManager.default.removeItem(at: baseExportPath)
    }
  }
  
  var baseExportPath: URL? { FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.appendingPathComponent(appName) }
  
  func baseImage<IconView: View>(for iconView: IconView, scale: IconScale) -> some View {
    iconView
//    guard let imageData = ImageRenderer.renderData(view: iconView,
//                                                   size: CGSize(width: 1024 * scale.widthScale,
//                                                                height: 1024 * scale.heightScale),
//                                                   sizeIsPixels: true),
//          let nsImage = NSImage(data: imageData)
//    else { return AnyView(Color.clear) }
//    
//    return AnyView(Image(nsImage)
//      .resizable()
//      .aspectRatio(contentMode: .fill))
  }
  
//  public func exportAllIcons<AppIcon: BaseAppIcon>(iconType: AppIcon.Type) async throws {
//    if let iOSIcons = (iconType as? IOSAppIcon)?.allIcons {
//      export(iOSIcons: iOSIcons)
//    }
//  }
  
  public func export(watchOSIcon icon: some WatchAppIcon) async throws {
    guard let exportPath = baseExportPath?.appendingPathComponent("watchOS") else { return }
    let iconExportPath = exportPath.appendingPathComponent("\(icon.imageName).appiconset")
    try? FileManager.default.createDirectory(at: iconExportPath, withIntermediateDirectories: true, attributes: [:])
    
    for scale in IconScale.watchOSIconScales {
      try await save(view: baseImage(for: icon.watchOSView.flattenedView, scale: scale), size: scale.size * CGFloat(scale.scaleFactor),
                     to: iconExportPath.appendingPathComponent(AppiconsetContentsGenerator.fileName(appIconName: icon.imageName, scale: scale)),
                     allowOpacity: false)
      try AppiconsetContentsGenerator.contentsFile(for: icon.imageName, with: IconScale.watchOSIconScales)
        .write(to: iconExportPath.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
    }
  }
  
  public func export(iMessageIcon icon: some IMessageAppIcon) async throws {
    guard let exportPath = baseExportPath?.appendingPathComponent("iMessage") else { return }
    let iconExportPath = exportPath.appendingPathComponent("\(icon.imageName).stickersiconset")
    try? FileManager.default.createDirectory(at: iconExportPath, withIntermediateDirectories: true, attributes: [:])
    
    for scale in IconScale.iMessageIconScales {
      try await save(view: baseImage(for: icon.iMessageView.flattenedView, scale: scale), size: scale.size * CGFloat(scale.scaleFactor),
                     to: iconExportPath.appendingPathComponent(AppiconsetContentsGenerator.fileName(appIconName: icon.imageName, scale: scale)),
                     allowOpacity: false)
      try AppiconsetContentsGenerator.contentsFile(for: icon.imageName, with: IconScale.iMessageIconScales)
        .write(to: iconExportPath.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
    }
  }
  
  public func export(visionOSIcons icons: [any VisionOSAppIcon]) async throws {
    guard let exportPath = baseExportPath?.appendingPathComponent("visionOS") else { return }
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
        try? AppIconEmptyContents().jsonData.write(to: iconLayerURL.appendingPathComponent("Contents.json"))
        
        let imageLayerName = "\(icon.imageName)-\(layerName)"
        try await save(view: baseImage(for: layer, scale: scale), size: scale.size * CGFloat(scale.scaleFactor),
                       to: iconLayerInnerContentsURL.appendingPathComponent(AppiconsetContentsGenerator.fileName(appIconName: imageLayerName, scale: scale)),
                       allowOpacity: i != icon.visionOSView.layers.count - 1)
        try AppiconsetContentsGenerator.contentsFile(for: imageLayerName, with: [scale])
          .write(to: iconLayerInnerContentsURL.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
      }
      try? layerContents.jsonData.write(to: iconExportPath.appendingPathComponent("Contents.json"))
    }
  }
  
  public func exportThumbnails(iOSIcons icons: [any IOSAppIcon]) async throws {
    guard let exportPath = baseExportPath?.appendingPathComponent("ios-thumbnails") else { return }
    try? FileManager.default.createDirectory(at: exportPath, withIntermediateDirectories: true, attributes: [:])
    for icon in icons {
      try await save(view: icon.iOSView.light.flattenedView, size: CGSize(width: 180, height: 180),
                     to: exportPath.appendingPathComponent(AppIconAssetsContents.iOSFileName(appIconName: icon.imageName, suffix: "")),
                     allowOpacity: false)
    }
  }
  
  public func exportThumbnails(iOSIconsPairs icons: [(name: String, icon: any IOSAppIcon)]) async throws {
    guard let exportPath = baseExportPath?.appendingPathComponent("ios-thumbnails") else { return }
    try? FileManager.default.createDirectory(at: exportPath, withIntermediateDirectories: true, attributes: [:])
    for icon in icons {
      try await save(view: icon.icon.iOSView.light.flattenedView, size: CGSize(width: 180, height: 180),
                     to: exportPath.appendingPathComponent(AppIconAssetsContents.iOSFileName(appIconName: icon.name, suffix: "")),
                     allowOpacity: false)
    }
  }
  
  public func export(iOSIcons icons: [any IOSAppIcon]) async throws {
    guard let exportPath = baseExportPath?.appendingPathComponent("ios") else { return }
    for icon in icons {
      let iconExportPath = exportPath.appendingPathComponent("\(icon.imageName).appiconset")
      try? FileManager.default.createDirectory(at: iconExportPath, withIntermediateDirectories: true, attributes: [:])
      
      try await save(view: icon.iOSView.light.flattenedView, size: CGSize(width: 1024, height: 1024),
                     to: iconExportPath.appendingPathComponent(AppIconAssetsContents.iOSFileName(appIconName: icon.imageName, suffix: "")),
                     allowOpacity: false)
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
    }
  }
  
  public func export<AppIcon: MacOSAppIcon>(macIcons icons: [AppIcon]) async throws {
    guard let exportPath = baseExportPath?.appendingPathComponent("macOS") else { return }
    
    // Main App Icon
    let mainIconExportPath = exportPath.appendingPathComponent("AppIcon.appiconset")
    try? FileManager.default.createDirectory(at: mainIconExportPath, withIntermediateDirectories: true, attributes: [:])
    
    // Main App Icon
    for scale in IconScale.macOSMainIconScales {
      try await save(view: baseImage(for: AppIcon.defaultIcon.macOSView.view.flattenedView, scale: scale), size: scale.size * CGFloat(scale.scaleFactor),
                     to: mainIconExportPath.appendingPathComponent(AppiconsetContentsGenerator.fileName(appIconName: AppIcon.defaultIcon.imageName, scale: scale)),
                     allowOpacity: true)
    }
    try? AppiconsetContentsGenerator.contentsFile(for: AppIcon.defaultIcon.imageName, with: IconScale.macOSMainIconScales)
      .write(to: mainIconExportPath.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
    
    for icon in icons {
      try? FileManager.default.createDirectory(at: exportPath, withIntermediateDirectories: true, attributes: [:])
      
      try await save(view: baseImage(for: icon.macOSView.view.flattenedView, scale: .init(size: CGSize(width: 256, height: 256), scaleFactor: 1, purpose: .mac)),
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
  func save<Content: View>(view: Content, size: CGSize, to path: URL, allowOpacity: Bool) async throws {
    let imageRender = ImageRenderer(content: view.frame(size))
    imageRender.isOpaque = !allowOpacity
    //    imageRender.proposedSize = size
    guard let cgImage = imageRender.cgImage else { throw AppIconCreateError.failedToRender }
    let data = NSMutableData()
    let downsampleOptions = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceShouldCacheImmediately: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageDestinationLossyCompressionQuality: 0.9,
    ] as [NSObject: AnyObject] as [AnyHashable: Any] as CFDictionary
    
    guard let destination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, downsampleOptions) else { throw AppIconCreateError.failedGetData }
    CGImageDestinationAddImage(destination, cgImage, downsampleOptions)
    guard CGImageDestinationFinalize(destination) else { throw AppIconCreateError.failedGetData }
    try data.write(to: path)
  }
}
