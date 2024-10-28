import SwiftUI

import HelloCore
import HelloApp

public struct KnownAppIconView: View {
  
  @Environment(\.theme) var theme
  
  var app: KnownApp
  var prefferedPlatform: HelloAppPlatform?
  
  private var effectivePlatform: HelloAppPlatform? {
    if let prefferedPlatform, app.platforms.contains(prefferedPlatform) {
      prefferedPlatform
    } else {
      app.platforms.first
    }
  }
  
  public var body: some View {
    switch effectivePlatform {
    case .iOS:
      HelloImageView(.asset(bundle: .helloAppMain, named: app.id + "-ios"))
        .clipShape(AppIconShape())
        .overlay(AppIconShape().stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
    case .iMessage:
      HelloImageView(.asset(bundle: .helloAppMain, named: app.id + "-imessage"))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
    case .watchOS:
      HelloImageView(.asset(bundle: .helloAppMain, named: app.id + "-watchos"))
        .clipShape(Circle())
        .overlay(Circle().stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
    case .visionOS:
      HelloImageView(.asset(bundle: .helloAppMain, named: app.id + "-visionos"))
        .clipShape(Circle())
        .overlay(Circle().stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
    case .macOS:
      HelloImageView(.asset(bundle: .helloAppMain, named: app.id + "-macos"))
        .clipShape(MacAppIconShape())
        .overlay(MacAppIconShape().stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
    case nil:
      Color.clear
    }
  }
}

public struct AppIconView: View {
  
  @Environment(\.theme) private var theme
  
  private var icon: any HelloAppIcon
  
  public init(icon: some HelloAppIcon) {
    self.icon = icon
  }
  
  public var body: some View {
    HelloImageView(.appIconThumbnail(for: icon))
    //    icon.view.flattenedView
      .clipShape(AppIconShape())
      .overlay(AppIconShape().stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
  }
}
