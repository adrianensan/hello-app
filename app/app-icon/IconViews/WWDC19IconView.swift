import SwiftUI

import HelloCore

public struct WWDC19IconView: View {
  
  let characterView: AnyView
  
  public init<CharacterView: View>(outlineCharacterView: CharacterView) {
    self.characterView = AnyView(outlineCharacterView)
  }
  
  var offset: CGFloat {
    0.0175
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        characterView
          .compositingGroup()
          .shadow(color: .white, radius: 0.025 * geometry.size.minSide)
        characterView
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
