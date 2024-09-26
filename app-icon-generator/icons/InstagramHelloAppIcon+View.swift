import Foundation

import HelloCore
import HelloApp

extension InstagramHelloAppIcon: HelloSwiftUIAppIcon {
  public func baseView(context: AppIconExporterContext) -> HelloAppIconViewLayers {
    .init { InstagramAppIconView(icon: context.iconFill) }
  }
}

