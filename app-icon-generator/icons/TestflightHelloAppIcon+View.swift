import Foundation

import HelloCore
import HelloApp

extension TestflightHelloAppIcon: HelloSwiftUIAppIcon {
  public func baseView(context: AppIconExporterContext) -> HelloAppIconViewLayers {
    .init { TestflightAppIconView(iconFillView: context.iconFill, iconStrokeView: context.iconStroke) }
  }
}

