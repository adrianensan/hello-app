import SwiftUI

import HelloCore

@MainActor
public struct AppIconExporterContext: Sendable {
  public var appID: String
  public var platform: HelloAppPlatform
  public var size: CGSize
  
  public var iconFill: AnyView
  public var iconStroke: (_ lineWidth: CGFloat) -> AnyView
  
  public func with(size: CGSize) -> AppIconExporterContext {
    AppIconExporterContext(appID: appID, platform: platform, size: size, iconFill: iconFill, iconStroke: iconStroke)
  }
}
