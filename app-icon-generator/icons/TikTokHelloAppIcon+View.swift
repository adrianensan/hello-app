import Foundation

import HelloCore
import HelloApp

extension TikTokHelloAppIcon: HelloSwiftUIAppIcon {
  public func baseView(context: AppIconExporterContext) -> HelloAppIconViewLayers {
    .init { TikTokAppIconView(icon: context.iconFill) }
  }
}

