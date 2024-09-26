import SwiftUI

public struct PlaceholderIconBackground: View {
  
  var lineWidth: CGFloat { 0.004 }
  
  public init() {}
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        ZStack {
          HStack(spacing: 0) {
            Rectangle()
              .fill()
              .frame(maxWidth: lineWidth * geometry.size.width,
                     maxHeight: .infinity)
            Spacer(minLength: 0)
            Rectangle()
              .fill()
              .frame(maxWidth: lineWidth * geometry.size.width,
                     maxHeight: .infinity)
          }
          VStack(spacing: 0) {
            Rectangle()
              .fill()
              .frame(maxWidth: .infinity,
                     maxHeight: lineWidth * geometry.size.width)
            Spacer(minLength: 0)
            Rectangle()
              .fill()
              .frame(maxWidth: .infinity,
                     maxHeight: lineWidth * geometry.size.width)
          }
          Circle()
            .strokeBorder(lineWidth: lineWidth * geometry.size.width)
        }.padding(0.054 * geometry.size.width)
        HStack(spacing: 0) {
          Spacer(minLength: 0)
          Rectangle()
            .fill()
            .frame(maxWidth: lineWidth * geometry.size.width,
                   maxHeight: .infinity)
          Spacer(minLength: 0)
          Rectangle()
            .fill()
            .frame(maxWidth: lineWidth * geometry.size.width,
                   maxHeight: .infinity)
          Spacer(minLength: 0)
        }
        VStack(spacing: 0) {
          Spacer(minLength: 0)
          Rectangle()
            .fill()
            .frame(maxWidth: .infinity,
                   maxHeight: lineWidth * geometry.size.width)
          Spacer(minLength: 0)
          Rectangle()
            .fill()
            .frame(maxWidth: .infinity,
                   maxHeight: lineWidth * geometry.size.width)
          Spacer(minLength: 0)
        }
        
//        Circle()
//          .strokeBorder(lineWidth: lineWidth * geometry.size.width)
//          .frame(1/3 * geometry.size.minSide)
//        
//        Circle()
//          .strokeBorder(lineWidth: lineWidth * geometry.size.width)
//          .frame(1/2 * geometry.size.minSide)
        
        Rectangle()
          .fill()
          .frame(maxWidth: lineWidth * geometry.size.width,
                 maxHeight: .infinity)
        Rectangle()
          .fill()
          .frame(maxWidth: .infinity,
                 maxHeight: lineWidth * geometry.size.width)
        ZStack {
          Rectangle()
            .fill()
            .frame(width: geometry.size.diagonal, height: lineWidth * geometry.size.width)
            .rotationEffect(.radians(-0.25 * .pi))
          Rectangle()
            .fill()
            .frame(width: geometry.size.diagonal, height: lineWidth * geometry.size.width)
            .rotationEffect(.radians(0.25 * .pi))
//          Rectangle()
//            .fill()
//            .frame(maxWidth: .infinity,
//                   maxHeight: lineWidth * geometry.size.width)
//            .rotationEffect(.radians(-0.25 * .pi))
//            .offset(x: -0.5 * geometry.size.width, y: 0.5 * geometry.size.height)
//          Rectangle()
//            .fill()
//            .frame(maxWidth: .infinity,
//                   maxHeight: lineWidth * geometry.size.width)
//            .rotationEffect(.radians(-0.25 * .pi))
//            .offset(x: 0.5 * geometry.size.width, y: -0.5 * geometry.size.height)
        }.frame(width: geometry.size.width, height: geometry.size.height)
      }
    }
  }
}
