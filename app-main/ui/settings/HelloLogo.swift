import SwiftUI

public struct HelloLogo: View {
  
  public init() {
    
  }
  
  public var body: some View {
    GeometryReader { geometry in
      let size: CGFloat = geometry.size.minSide
      let strokeSize: CGFloat = 0.1 * size
      let sideLength: CGFloat = size / sin(.pi / 3)
      ZStack {
        Capsule(style: .continuous)
          .fill()
          .frame(width: strokeSize, height: sideLength)
          .offset(x: -0.5 * size)
        
        Capsule(style: .continuous)
          .fill()
          .frame(width: strokeSize, height: 0.8 * sideLength)
          .offset(x: -0.3 * size)
        
        Capsule(style: .continuous)
          .fill()
          .frame(width: strokeSize, height: 0.6 * sideLength)
          .offset(x: -0.1 * size)
        
        Capsule(style: .continuous)
          .fill()
          .frame(width: strokeSize, height: 0.4 * sideLength)
          .offset(x: 0.1 * size)
        
        Capsule(style: .continuous)
          .fill()
          .frame(width: strokeSize, height: 0.2 * sideLength)
          .offset(x: 0.3 * size)
        
        Capsule(style: .continuous)
          .fill()
          .frame(width: 0.4 * size, height: strokeSize)
          .frame(width: 0, alignment: .leading)
          .offset(x: -0.5 * size)
        
        Capsule(style: .continuous)
          .fill()
          .frame(width: 0.8 * sideLength - 0.4 * strokeSize, height: strokeSize)
          .padding(.trailing, 0.5 * strokeSize)
          .frame(width: size, alignment: .trailing)
        //.offset(x: 0.1 * sideLength)
          .rotationEffect(.degrees(-30), anchor: .trailing)
          .offset(y: -0.45 * strokeSize)
        
        Capsule(style: .continuous)
          .fill()
          .frame(width: 0.2 * sideLength - 0.4 * strokeSize, height: strokeSize)
          .padding(.trailing, 0.5 * strokeSize)
          .frame(width: size, alignment: .trailing)
        //.offset(x: 0.1 * sideLength)
          .rotationEffect(.degrees(30), anchor: .trailing)
          .offset(y: 0.45 * strokeSize)
        
        Capsule(style: .continuous)
          .fill()
          .frame(width: 0.2 * sideLength + 0.8 * strokeSize, height: strokeSize)
          .frame(width: 0.8 * sideLength + 0.4 * strokeSize, height: strokeSize, alignment: .leading)
          .frame(width: size, alignment: .trailing)
          .rotationEffect(.degrees(30), anchor: .trailing)
          .offset(y: 0.45 * strokeSize)
      }.compositingGroup()
      .frame(width: size, height: size)
      .frame(width: sideLength, height: sideLength)
      .rotationEffect(.degrees(30))
      .offset(x: 0.2 * size, y: 0.2 * size)
      .frame(width: size, height: size)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      //.rotationEffect(.degrees(-120))
    }
  }
}
