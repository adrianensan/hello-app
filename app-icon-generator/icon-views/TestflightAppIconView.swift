import SwiftUI

import HelloCore
import HelloApp

public struct TestflightAppIconView: View {
  
  var iconFillView: AnyView
  var iconStrokeView: (CGFloat) -> AnyView
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        AppIconShape()
          .stroke(.white, lineWidth: 0.012 * geometry.size.minSide)
          .padding(0.06 * geometry.size.minSide)
        
        iconFillView
          .foregroundStyle(.white.opacity(0.36))
        
        iconStrokeView(0.012)
          .foregroundStyle(.white)
        
//        HelloPodcastsAppIconCharacter(style: .custom(SimpleOutlinedCharacterStyle(fillColor: .white.opacity(0.36), outlineColor: .white, outlineWidth: 0.012)))
        //          .frame(0.75 * geometry.size.minSide)
      }.frame(width: geometry.size.width, height: geometry.size.height)
        .background(LinearGradient(colors: [HelloColor(r: 0.34, g: 0.71, b: 0.92).swiftuiColor,
                                            HelloColor(r: 0.19, g: 0.38, b: 0.85).swiftuiColor],
                                   startPoint: .top, endPoint: .bottom))
    }
  }
}
