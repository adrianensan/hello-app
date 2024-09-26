import Foundation

import HelloCore
import HelloApp

extension WWDC19HelloAppIcon: HelloSwiftUIAppIcon {
  public func baseView(context: AppIconExporterContext) -> HelloAppIconViewLayers {
    .init { WWDC19AppIconView(iconStrokeView: context.iconStroke) }
  }
}

