import SwiftUI

import HelloCore

public struct DepthIconView: View {
  
  let characterView: AnyView
  
  public init<CharacterView: View>(characterView: CharacterView) {
    self.characterView = AnyView(characterView)
  }
  
  var offset: CGFloat {
    0.01
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        HelloColor.retroApple.blue.swiftuiColor
          .mask {
            ZStack {
              characterView
                .offset(x: -0.9 * offset * geometry.size.width, y: -0.9 * offset * geometry.size.height)
              characterView
                .offset(x: -0.75 * offset * geometry.size.width, y: -0.75 * offset * geometry.size.height)
              characterView
                .offset(x: -0.5 * offset * geometry.size.width, y: -0.5 * offset * geometry.size.height)
              characterView
                .offset(x: -0.25 * offset * geometry.size.width, y: -0.25 * offset * geometry.size.height)
              characterView
              characterView
                .offset(x: 0.25 * offset * geometry.size.width, y: 0.25 * offset * geometry.size.height)
              characterView
                .offset(x: 0.5 * offset * geometry.size.width, y: 0.5 * offset * geometry.size.height)
              characterView
                .offset(x: 0.75 * offset * geometry.size.width, y: 0.75 * offset * geometry.size.height)
              characterView
                .offset(x: offset * geometry.size.width, y: offset * geometry.size.height)
            }
          }
          
        characterView
          .offset(x: -offset * geometry.size.width, y: -offset * geometry.size.height)
      }.frame(width: geometry.size.width, height: geometry.size.height)
        .background(HelloColor.black.swiftuiColor)
    }
  }
}
