import SwiftUI

import HelloCore

public struct TikTokIconView: View {
  
  let characterView: AnyView
  
  public init<CharacterView: View>(characterView: CharacterView) {
    self.characterView = AnyView(characterView)
  }
  
  var offset: CGFloat {
    0.0175
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        Color(.sRGB, red: 0.12, green: 0.96, blue: 0.93, opacity: 1)
          .mask(characterView)
          .offset(x: -offset * geometry.size.width, y: -offset * geometry.size.height)
          .drawingGroup()
        Color(.sRGB, red: 0.98, green: 0.18, blue: 0.33, opacity: 1)
          .mask(characterView)
          .offset(x: offset * geometry.size.width, y: offset * geometry.size.height)
          .drawingGroup()
        characterView
          .offset(x: -offset * geometry.size.width, y: -offset * geometry.size.height)
          .mask(characterView
                  .offset(x: offset * geometry.size.width, y: offset * geometry.size.height))
      }.frame(width: geometry.size.width, height: geometry.size.height)
        .background(HelloColor.black.swiftuiColor)
        .drawingGroup()
    }
  }
}
