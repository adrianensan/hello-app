import SwiftUI

import HelloCore
import HelloApp

public struct PlaceholderHelloAppIconView: View {
  
  var iconFillView: AnyView
  var iconStrokeView: (CGFloat) -> AnyView
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        PlaceholderIconBackground()
          .frame(width: geometry.size.width, height: geometry.size.height)
          .mask {
            ZStack {
              Rectangle().fill(.white)
              iconFillView.foregroundStyle(.black)
            }.compositingGroup()
              .luminanceToAlpha()
          }
        
        iconStrokeView(0.01)
        
        //        HelloPodcastsAppIconCharacter(style: .custom(SimpleOutlinedCharacterStyle(fillColor: .white.opacity(0.36), outlineColor: .white, outlineWidth: 0.012)))
        //          .frame(0.75 * geometry.size.minSide)
      }.frame(width: geometry.size.width, height: geometry.size.height)
    }
  }
}
