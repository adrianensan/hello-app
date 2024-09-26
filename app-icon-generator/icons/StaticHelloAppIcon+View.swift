import Foundation

import HelloCore
import HelloApp

extension StaticHelloAppIcon: HelloSwiftUIAppIcon {
  public func baseView(context: AppIconExporterContext) -> HelloAppIconViewLayers {
    .init { StaticAppIconView(icon: context.iconFill) }
  }
}

