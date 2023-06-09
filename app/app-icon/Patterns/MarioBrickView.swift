import SwiftUI

import HelloCore

public struct MarioBrickView: View {
  
  var brickSpacing: CGFloat { 0.08 }
  
  var brickSize: CGSize {
    CGSize(width: 0.5 * (1 - 2 * brickSpacing),
           height: 0.25 * (1 - 4 * brickSpacing))
  }
  
  public init() {}
  
  public var body: some View {
    GeometryReader { geometry in
      VStack(spacing: brickSpacing * geometry.size.width) {
        ForEach(0..<Int(ceil(geometry.size.height / ((brickSize.height + brickSpacing) * geometry.size.width))), id: \.self) { row in
          HStack(spacing: 0) {
            if row % 2 == 0 {
              Rectangle()
                .fill(HelloColor.mario.brick.swiftuiColor)
                .frame(width: brickSize.width * geometry.size.width,
                       height: brickSize.height * geometry.size.width)
              Spacer(minLength: 0)
              Rectangle()
                .fill(HelloColor.mario.brick.swiftuiColor)
                .frame(width: brickSize.width * geometry.size.width,
                       height: brickSize.height * geometry.size.width)
              Spacer(minLength: 0)
            } else {
              Rectangle()
                .fill(HelloColor.mario.brick.swiftuiColor)
                .frame(width: (0.5 * (brickSize.width - brickSpacing)) * geometry.size.width,
                       height: brickSize.height * geometry.size.width)
              Spacer(minLength: 0)
              Rectangle()
                .fill(HelloColor.mario.brick.swiftuiColor)
                .frame(width: brickSize.width * geometry.size.width,
                       height: brickSize.height * geometry.size.width)
              Spacer(minLength: 0)
              Rectangle()
                .fill(HelloColor.mario.brick.swiftuiColor)
                .frame(width: (0.5 * (brickSize.width + brickSpacing)) * geometry.size.width,
                       height: brickSize.height * geometry.size.width)
            }
          }
        }
        Spacer(minLength: 0)
      }.frame(width: geometry.size.width, height: geometry.size.height)
        .background(HelloColor.black.swiftuiColor)
    }
  }
}
