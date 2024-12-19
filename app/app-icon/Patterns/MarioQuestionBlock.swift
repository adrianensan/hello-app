import SwiftUI

import HelloCore

public struct QuestionBlockView: View {
  
  var color: HelloColor
  
  public init(color: HelloColor = .mario.questionBlock) {
    self.color = color
  }
  
  var darkColor: Color {
    color.brightness(-0.12).swiftuiColor
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        ZStack {
          Circle()
            .fill(darkColor)
            .frame(width: 0.15 * geometry.size.width, height: 0.15 * geometry.size.width)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
          Circle()
            .fill(darkColor)
            .frame(width: 0.15 * geometry.size.width, height: 0.15 * geometry.size.width)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
          Circle()
            .fill(darkColor)
            .frame(width: 0.15 * geometry.size.width, height: 0.15 * geometry.size.width)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
          Circle()
            .fill(darkColor)
            .frame(width: 0.15 * geometry.size.width, height: 0.15 * geometry.size.width)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }.padding(0.075 * geometry.size.width)
        Text("?")
          .font(.custom("LCD Solid", fixedSize: 0.9 * geometry.size.width))
          .offset(y: 0.05 * geometry.size.width)
          .foregroundStyle(color.readableOverlayColor.swiftuiColor)
      }.background(color.swiftuiColor)
    }
  }
}
