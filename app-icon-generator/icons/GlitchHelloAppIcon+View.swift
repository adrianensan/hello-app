import Foundation

import HelloCore
import HelloApp

extension GlitchHelloAppIcon: HelloSwiftUIAppIcon {
  public func baseView(context: AppIconExporterContext) -> HelloAppIconViewLayers {
    .init { GlitchAppIconView(characterView: context.iconFill) }
  }
}

