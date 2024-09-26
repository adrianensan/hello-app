import Foundation
import SwiftUI

import HelloCore
import HelloApp

@MainActor
public protocol HelloSwiftUIAppIcon: HelloAppIcon {
  var baseView: HelloAppIconViewLayers { get }
  func baseView(context: AppIconExporterContext) -> HelloAppIconViewLayers
  func iosView(context: AppIconExporterContext) -> HelloIOSAppIconView
  func macosView(context: AppIconExporterContext) -> MacAppIconView
  func imessageView(context: AppIconExporterContext) -> HelloAppIconViewLayers
  func watchosView(context: AppIconExporterContext) -> HelloAppIconViewLayers
  func visionosView(context: AppIconExporterContext) -> HelloAppIconViewLayers
  func tvosView(context: AppIconExporterContext) -> HelloAppIconViewLayers
}

@MainActor
public protocol HelloSwiftUIImageAppIcon: HelloSwiftUIAppIcon {
  var imageSource: HelloImageOption { get }
}
  
public extension HelloSwiftUIImageAppIcon {
  var baseView: HelloAppIconViewLayers { .init {
    HelloImageView(options: [imageSource], load: .sync, resizeMode: .fill)
  } }
}

public extension HelloSwiftUIAppIcon {
  var baseView: HelloAppIconViewLayers { fatalError("No app icon view provided for \(id)") }
  func baseView(context: AppIconExporterContext) -> HelloAppIconViewLayers { baseView }
  func iosView(context: AppIconExporterContext) -> HelloIOSAppIconView { .classic(baseView(context: context)) }
  func macosView(context: AppIconExporterContext) -> MacAppIconView { .unmasked(baseView(context: context)) }
  func imessageView(context: AppIconExporterContext) -> HelloAppIconViewLayers { baseView(context: context) }
  func watchosView(context: AppIconExporterContext) -> HelloAppIconViewLayers { baseView(context: context) }
  func visionosView(context: AppIconExporterContext) -> HelloAppIconViewLayers { baseView(context: context) }
  func tvosView(context: AppIconExporterContext) -> HelloAppIconViewLayers { baseView(context: context) }
}
