import Foundation

import HelloCore
import HelloApp

extension DefaultStandardTintHelloAppIcon: HelloSwiftUIAppIcon {
  public func baseView(context: AppIconExporterContext) -> HelloAppIconViewLayers {
    .init { StandardAppIconView(characterView: context.iconFill, tint: tint) }
  }
  
  public func iosView(context: AppIconExporterContext) -> HelloIOSAppIconView {
    .auto(icon: context.iconFill, tint: tint)
  }
}

