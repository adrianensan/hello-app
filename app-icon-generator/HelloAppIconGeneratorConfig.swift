import SwiftUI

import HelloCore
import HelloApp

public protocol HelloAppIconGeneratorConfig: HelloAppIconConfig {
  @MainActor var iconFill: AnyView { get }
  @MainActor func iconStroke(lineWidth: CGFloat) -> AnyView
}

public extension HelloAppIconGeneratorConfig {
  
  var defaultGeneratable: any HelloSwiftUIAppIcon {
    guard let genaratableIcon = defaultIcon as? any HelloSwiftUIAppIcon else {
      fatalError("\(defaultIcon.systemName) does not conform to HelloSwiftUIAppIcon")
    }
    return genaratableIcon
  }
  
  var allGenaratable: [any HelloSwiftUIAppIcon] {
    var genaratableIcons: [any HelloSwiftUIAppIcon] = []
    for icon in all {
      guard let genaratableIcon = icon as? any HelloSwiftUIAppIcon else {
        fatalError("\(icon.systemName) does not conform to HelloSwiftUIAppIcon")
      }
      genaratableIcons.append(genaratableIcon)
    }
    return genaratableIcons
  }

  @MainActor
  public var iconFill: AnyView { AnyView(HelloEyes().foregroundStyle(.white)) }

  @MainActor
  public func iconStroke(lineWidth: CGFloat) -> AnyView {
    AnyView(OutlineHelloEyes(strokeWidth: lineWidth))
  }
}
