import Foundation

import HelloCore
import HelloApp

extension GoldHelloAppIcon: HelloSwiftUIAppIcon {
  public func baseView(context: AppIconExporterContext) -> HelloAppIconViewLayers {
    .init { GoldAppIconView(iconView: context.iconFill) }
  }
}

