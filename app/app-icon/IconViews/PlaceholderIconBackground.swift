import SwiftUI

struct PlaceholderIconBackground: View {
  
  var lineWidth: CGFloat { 0.01 }
  
  var color: Color = .white
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        ZStack {
          HStack(spacing: 0) {
            Rectangle()
              .fill(color)
              .frame(maxWidth: lineWidth * geometry.size.width,
                     maxHeight: .infinity)
            Spacer(minLength: 0)
            Rectangle()
              .fill(color)
              .frame(maxWidth: lineWidth * geometry.size.width,
                     maxHeight: .infinity)
          }
          VStack(spacing: 0) {
            Rectangle()
              .fill(color)
              .frame(maxWidth: .infinity,
                     maxHeight: lineWidth * geometry.size.width)
            Spacer(minLength: 0)
            Rectangle()
              .fill(color)
              .frame(maxWidth: .infinity,
                     maxHeight: lineWidth * geometry.size.width)
          }
          Circle()
            .strokeBorder(color, lineWidth: lineWidth * geometry.size.width)
        }.padding(0.05 * geometry.size.width)
        HStack(spacing: 0) {
          Spacer(minLength: 0)
          Rectangle()
            .fill(color)
            .frame(maxWidth: lineWidth * geometry.size.width,
                   maxHeight: .infinity)
          Spacer(minLength: 0)
          Rectangle()
            .fill(color)
            .frame(maxWidth: lineWidth * geometry.size.width,
                   maxHeight: .infinity)
          Spacer(minLength: 0)
        }
        VStack(spacing: 0) {
          Spacer(minLength: 0)
          Rectangle()
            .fill(color)
            .frame(maxWidth: .infinity,
                   maxHeight: lineWidth * geometry.size.width)
          Spacer(minLength: 0)
          Rectangle()
            .fill(color)
            .frame(maxWidth: .infinity,
                   maxHeight: lineWidth * geometry.size.width)
          Spacer(minLength: 0)
        }
        Rectangle()
          .fill(color)
          .frame(maxWidth: lineWidth * geometry.size.width,
                 maxHeight: .infinity)
        Rectangle()
          .fill(color)
          .frame(maxWidth: .infinity,
                 maxHeight: lineWidth * geometry.size.width)
        ZStack {
          Rectangle()
            .fill(color)
            .frame(maxWidth:.infinity,
                   maxHeight: lineWidth * geometry.size.width)
            .rotationEffect(.radians(0.25 * .pi))
            .offset(x: -0.5 * geometry.size.width, y: -0.5 * geometry.size.height)
          Rectangle()
            .fill(color)
            .frame(maxWidth:.infinity,
                   maxHeight: lineWidth * geometry.size.width)
            .rotationEffect(.radians(0.25 * .pi))
            .offset(x: 0.5 * geometry.size.width, y: 0.5 * geometry.size.height)
          Rectangle()
            .fill(color)
            .frame(maxWidth: .infinity,
                   maxHeight: lineWidth * geometry.size.width)
            .rotationEffect(.radians(-0.25 * .pi))
            .offset(x: -0.5 * geometry.size.width, y: 0.5 * geometry.size.height)
          Rectangle()
            .fill(color)
            .frame(maxWidth: .infinity,
                   maxHeight: lineWidth * geometry.size.width)
            .rotationEffect(.radians(-0.25 * .pi))
            .offset(x: 0.5 * geometry.size.width, y: -0.5 * geometry.size.height)
        }
      }
    }
  }
}
