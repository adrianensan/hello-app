import SwiftUI

import HelloCore

public struct TikTokAppIconView: View {
  
  let icon: AnyView
  
  public init(icon: some View) {
    self.icon = AnyView(icon)
  }
  
  var offset: CGFloat {
    0.0175
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        Color(.sRGB, red: 0.12, green: 0.96, blue: 0.93, opacity: 1)
          .mask(icon)
          .offset(x: -offset * geometry.size.width, y: -offset * geometry.size.height)
          .drawingGroup()
        Color(.sRGB, red: 0.98, green: 0.18, blue: 0.33, opacity: 1)
          .mask(icon)
          .offset(x: offset * geometry.size.width, y: offset * geometry.size.height)
          .drawingGroup()
        Color.white
          .mask(icon)
          .offset(x: -offset * geometry.size.width, y: -offset * geometry.size.height)
          .mask(icon
            .offset(x: offset * geometry.size.width, y: offset * geometry.size.height))
      }.frame(width: geometry.size.width, height: geometry.size.height)
        .background(HelloColor.black.swiftuiColor)
    }
  }
}
