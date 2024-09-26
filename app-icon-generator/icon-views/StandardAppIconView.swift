import SwiftUI

import HelloCore

public struct StandardAppIconView: View {
  
  let characterView: AnyView
  var tint: HelloAppIconTint
  
  var startAngle: Double { 0.075 }
  var totalAngle: Double { 0.1 }
  var nudge: Double { 0.0001 }
  
  public init<CharacterView: View>(characterView: CharacterView, tint: HelloAppIconTint) {
    self.characterView = AnyView(characterView)
    self.tint = tint
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        tint.background.view
        tint.foreground.view
          .mask(characterView)
          .frame(width: geometry.size.minSide, height: geometry.size.minSide)
          .foregroundStyle(tint.foreground.color.swiftuiColor)
      }.frame(width: geometry.size.width, height: geometry.size.height)
    }
  }
}
