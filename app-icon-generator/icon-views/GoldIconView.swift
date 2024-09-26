import SwiftUI

import HelloCore
import HelloApp

public struct GoldAppIconView: View {
  
  private var iconView: AnyView
  
  public init(iconView: some View) {
    self.iconView = AnyView(iconView)
  }
  
  public var body: some View {
    ZStack {
      HelloImageView(.asset(bundle: .helloAppIconGenerator, named: "gold-texture"), load: .sync)
//      iconView(.black.opacity(0.6))
      Color.black.opacity(0.8).mask {
        ZStack {
          Color.white
          Color.black.mask(iconView)
        }.compositingGroup()
          .luminanceToAlpha()
      }
      
      GeometryReader { geometry in
        Color.black
          .mask {
            Color.white.mask(iconView)
          }.shadow(color: .black.opacity(0.8),
                   radius: 0.02 * geometry.size.maxSide,
                   x: -0.01 * geometry.size.maxSide,
                   y: 0.01 * geometry.size.maxSide)
          .mask {
            ZStack {
              Color.white
              Color.black.mask(iconView)
            }.compositingGroup()
              .luminanceToAlpha()
          }
      }
      
//      GeometryReader { geometry in
//        Color.black
//          .mask {
//            ZStack {
//              Color.white
//              iconView(.black)
//            }.compositingGroup()
//              .luminanceToAlpha()
//          }.shadow(color: .black.opacity(0.8),
//                   radius: 0.02 * geometry.size.maxSide,
//                   x: -0.01 * geometry.size.maxSide,
//                   y: 0.01 * geometry.size.maxSide)
//          .mask {
//            iconView(.white)
//          }
//      }
    }
  }
}
