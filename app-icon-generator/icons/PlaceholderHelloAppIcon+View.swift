import SwiftUI

import HelloCore
import HelloApp

extension PlaceholderHelloAppIcon: HelloSwiftUIAppIcon {
  public func baseView(context: AppIconExporterContext) -> HelloAppIconViewLayers {
    .init(
      front: PlaceholderHelloAppIconView(iconFillView: context.iconFill, iconStrokeView: context.iconStroke)
        .foregroundStyle(HelloColor.greyscale(0.6).swiftuiColor),
      back: Color.white)
  }
  
  public func iosView(context: AppIconExporterContext) -> HelloIOSAppIconView {
    .variants(light: baseView(context: context),
              dark: .init(
                front: PlaceholderHelloAppIconView(iconFillView: context.iconFill, iconStrokeView: context.iconStroke)
                  .foregroundStyle(HelloColor.greyscale(0.5).swiftuiColor),
                back: Color.clear
              ),
              tintable: .init(
                front: PlaceholderHelloAppIconView(iconFillView: context.iconFill, iconStrokeView: context.iconStroke)
                  .foregroundStyle(HelloColor.greyscale(0.5).swiftuiColor),
                back: Color.black))
  }
}

