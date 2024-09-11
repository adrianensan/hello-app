import SwiftUI

import HelloCore

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
      HelloImageView(.asset(bundle: .helloApp, named: app.id + "-ios"))
        .clipShape(AppIconShape())
        .overlay(AppIconShape().stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
    case .iMessage:
      HelloImageView(.asset(bundle: .helloApp, named: app.id + "-imessage"))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
    case .watchOS:
      HelloImageView(.asset(bundle: .helloApp, named: app.id + "-watchos"))
        .clipShape(Circle())
        .overlay(Circle().stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
    case .visionOS:
      HelloImageView(.asset(bundle: .helloApp, named: app.id + "-visionos"))
        .clipShape(Circle())
        .overlay(Circle().stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
    case .macOS:
      HelloImageView(.asset(bundle: .helloApp, named: app.id + "-macos"))
        .clipShape(MacAppIconShape())
        .overlay(MacAppIconShape().stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
    case nil:
      Color.clear
    }
  }
}

public struct AppIconView: View {
  
  @Environment(\.theme) var theme
  
  var icon: any BaseAppIcon
  
  public init(icon: some BaseAppIcon) {
    self.icon = icon
  }
  
  public var body: some View {
    HelloImageView(.asset(named: icon.imageName))
//    icon.view.flattenedView
      .clipShape(AppIconShape())
      .overlay(AppIconShape().stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
  }
}

public struct IMessageAppIconView<AppIcon: BaseAppIcon>: View {
  
  @Environment(\.theme) var theme
  
  var icon: AppIcon
  
  var isSmall: Bool = false
  
  public var body: some View {
    HelloImageView(.asset(named: icon.imageName))
      .aspectRatio(0.75, contentMode: .fill)
    //    icon.view.flattenedView
      .clipShape(.capsule)
      .overlay(Capsule().stroke(theme.foreground.primary.style.opacity(0.1), lineWidth: 1))
  }
}
