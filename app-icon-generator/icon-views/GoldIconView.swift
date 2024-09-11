import SwiftUI

import HelloCore
import HelloApp

public struct GoldAppIconView<IconView: View>: View {
  
  private var iconView: @MainActor (HelloColor) -> IconView
  
  public init(iconView: @escaping @MainActor (HelloColor) -> IconView) {
    self.iconView = iconView
  }
  
  public var body: some View {
    ZStack {
      HelloImageView(.asset(bundle: .helloAppIconGenerator, named: "gold-texture"))
//      iconView(.black.opacity(0.6))
      Color.black.opacity(0.8).mask {
        ZStack {
          Color.white
          iconView(.black)
        }.compositingGroup()
          .luminanceToAlpha()
      }
      
      GeometryReader { geometry in
        Color.black
          .mask {
            iconView(.white)
          }.shadow(color: .black.opacity(0.8),
                   radius: 0.02 * geometry.size.maxSide,
                   x: -0.01 * geometry.size.maxSide,
                   y: 0.01 * geometry.size.maxSide)
          .mask {
            ZStack {
              Color.white
              iconView(.black)
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
