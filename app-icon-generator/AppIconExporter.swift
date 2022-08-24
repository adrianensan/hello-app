import SwiftUI
import UniformTypeIdentifiers

import HelloApp
import HelloCore

public struct AppIconExporter {
  
  let appName: String
  
  public init(appName: String) {
    self.appName = appName
  }
  
  var baseExportPath: URL? { FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.appendingPathComponent(appName) }
  
  func baseImage<IconView: View>(for iconView: IconView, scale: IconScale) -> AnyView {
    AnyView(iconView)
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
  
  public func export<AppIcon: WatchAppIcon>(watchOSIcon icon: AppIcon) async throws {
    guard let exportPath = baseExportPath?.appendingPathComponent("watchOS") else { return }
    let iconExportPath = exportPath.appendingPathComponent("\(icon.imageName).appiconset")
    try? FileManager.default.createDirectory(at: iconExportPath, withIntermediateDirectories: true, attributes: [:])
    
    for scale in IconScale.watchOSIconScales {
      try await save(view: baseImage(for: icon.watchView, scale: scale), size: scale.size * CGFloat(scale.scaleFactor),
           to: iconExportPath.appendingPathComponent(AppiconsetContentsGenerator.fileName(appIconName: icon.imageName, scale: scale)))
      try AppiconsetContentsGenerator.contentsFile(for: icon.imageName, with: IconScale.watchOSIconScales)
        .write(to: iconExportPath.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
    }
  }
  
  public func export<AppIcon: IMessageAppIcon>(iMessageIcon icon: AppIcon) async throws {
    guard let exportPath = baseExportPath?.appendingPathComponent("iMessage") else { return }
    let iconExportPath = exportPath.appendingPathComponent("\(icon.imageName).stickersiconset")
    try? FileManager.default.createDirectory(at: iconExportPath, withIntermediateDirectories: true, attributes: [:])
    
    for scale in IconScale.iMessageIconScales {
      try await save(view: baseImage(for: icon.iMessageView, scale: scale), size: scale.size * CGFloat(scale.scaleFactor),
           to: iconExportPath.appendingPathComponent(AppiconsetContentsGenerator.fileName(appIconName: icon.imageName, scale: scale)))
      try AppiconsetContentsGenerator.contentsFile(for: icon.imageName, with: IconScale.iMessageIconScales)
        .write(to: iconExportPath.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
    }
  }
  
  public func export<AppIcon: IOSAppIcon>(iOSIcons icons: [AppIcon]) async throws {
    guard let exportPath = baseExportPath?.appendingPathComponent("ios") else { return }
    for icon in AppIcon.allCases {
      let iconExportPath = exportPath.appendingPathComponent("\(icon.imageName).appiconset")
      try? FileManager.default.createDirectory(at: iconExportPath, withIntermediateDirectories: true, attributes: [:])
      
      // Main App Icon
      let scales = icon.imageName == AppIcon.defaultIcon.imageName ? IconScale.iOSMainIconScales : IconScale.iOSAlternateIconScales
      for scale in scales {
        try await save(view: baseImage(for: icon.iOSView, scale: scale), size: scale.size * CGFloat(scale.scaleFactor),
             to: iconExportPath.appendingPathComponent(AppiconsetContentsGenerator.fileName(appIconName: icon.imageName, scale: scale)))
      }
      try AppiconsetContentsGenerator.contentsFile(for: icon.imageName, with: scales)
        .write(to: iconExportPath.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
    }
  }
  
  public func export<AppIcon: MacAppIcon>(macIcons icons: [AppIcon]) async throws {
    guard let exportPath = baseExportPath?.appendingPathComponent("macOS") else { return }
    
    // Main App Icon
    let mainIconExportPath = exportPath.appendingPathComponent("AppIcon.appiconset")
    try? FileManager.default.createDirectory(at: mainIconExportPath, withIntermediateDirectories: true, attributes: [:])
    
    // Main App Icon
    for scale in IconScale.macOSMainIconScales {
      try await save(view: baseImage(for: AppIcon.defaultIcon.macView.view, scale: scale), size: scale.size * CGFloat(scale.scaleFactor),
           to: mainIconExportPath.appendingPathComponent(AppiconsetContentsGenerator.fileName(appIconName: AppIcon.defaultIcon.imageName, scale: scale)))
    }
    try? AppiconsetContentsGenerator.contentsFile(for: AppIcon.defaultIcon.imageName, with: IconScale.macOSMainIconScales)
      .write(to: mainIconExportPath.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
    
    for icon in AppIcon.allCases {
      try? FileManager.default.createDirectory(at: exportPath, withIntermediateDirectories: true, attributes: [:])
      
      try await save(view: baseImage(for: icon.macView.view, scale: .init(size: CGSize(width: 256, height: 256), scaleFactor: 1, purpose: .mac)),
           size: CGSize(width: 256, height: 256),
           to: exportPath.appendingPathComponent("\(icon.imageName).png"))
    }
  }
  
  enum AppIconCreateError: Error {
    case failedToRender
    case failedGetData
  }
  
  func save<Content: View>(view: Content, size: CGSize, to path: URL) async throws {
    if #available(iOS 16, macOS 13, *) {
      let imageRender = await ImageRenderer(content: view.frame(size))
      //    imageRender.proposedSize = size
      guard let cgImage = await imageRender.cgImage else { throw AppIconCreateError.failedToRender }
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
}
