import SwiftUI

import HelloCore

public struct QuestionBlockView: View {
  
  var color: HelloColor
  
  public init(color: HelloColor = .mario.questionBlock) {
    self.color = color
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        ZStack {
          Circle()
            .fill(color.darken().swiftuiColor)
            .frame(width: 0.15 * geometry.size.width, height: 0.15 * geometry.size.width)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
          Circle()
            .fill(color.darken().swiftuiColor)
            .frame(width: 0.15 * geometry.size.width, height: 0.15 * geometry.size.width)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
          Circle()
            .fill(color.darken().swiftuiColor)
            .frame(width: 0.15 * geometry.size.width, height: 0.15 * geometry.size.width)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
          Circle()
            .fill(color.darken().swiftuiColor)
            .frame(width: 0.15 * geometry.size.width, height: 0.15 * geometry.size.width)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }.padding(0.075 * geometry.size.width)
        Text("?")
          .font(.custom("LCD Solid", fixedSize: 0.9 * geometry.size.width))
          .offset(y: 0.05 * geometry.size.width)
          .foregroundColor(color.readableOverlayColor.swiftuiColor)
      }.background(color.swiftuiColor)
    }
  }
}
