import Foundation

import HelloCore
import HelloApp

extension StandardTintHelloAppIcon: HelloSwiftUIAppIcon {
  public func baseView(context: AppIconExporterContext) -> HelloAppIconViewLayers {
    .init { StandardAppIconView(characterView: context.iconFill, tint: tint) }
  }
}

