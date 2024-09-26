import Foundation

import HelloCore
import HelloApp

extension CRTHelloAppIcon: HelloSwiftUIAppIcon {
  public func baseView(context: AppIconExporterContext) -> HelloAppIconViewLayers {
    .init { CRTAppIconView(icon: context.iconFill) }
  }
}

