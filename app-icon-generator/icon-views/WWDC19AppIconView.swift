import SwiftUI

import HelloCore
import HelloApp

public struct WWDC19AppIconView: View {
  
  var iconStrokeView: (CGFloat) -> AnyView
  
  var offset: CGFloat {
    0.0175
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        iconStrokeView(0.015)
          .foregroundStyle(.white)
          .compositingGroup()
          .shadow(color: .white, radius: 0.025 * geometry.size.minSide)
        iconStrokeView(0.025)
          .foregroundStyle(.white)
          .compositingGroup()
          .shadow(color: .white, radius: 0.025 * geometry.size.minSide)
          .opacity(0.15)
          .offset(x: 0.03 * geometry.size.minSide, y: 0.03 * geometry.size.minSide)
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
      .background(Color(.sRGB, red: 0.08, green: 0.1, blue: 0.18, opacity: 1))
    }
  }
}
