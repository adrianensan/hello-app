import SwiftUI

import HelloCore

struct StandardIconBottomCurve: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    path.move(to: CGPoint(x: rect.minX, y: 0.74 * rect.maxY))
    path.addCurve(to: CGPoint(x: rect.maxX, y: 0.74 * rect.maxY),
                  control1: CGPoint(x: 0.025 * rect.maxX, y: 0.76 * rect.maxY),
                  control2: CGPoint(x: 0.975 * rect.maxX, y: 0.76 * rect.maxY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.closeSubpath()
    
    return path
  }
}


public struct StandardAppIconView: View {
  
  let characterView: AnyView
  var accentColor: HelloColor
  
  var startAngle: Double { 0.075 }
  var totalAngle: Double { 0.1 }
  var nudge: Double { 0.0001 }
  
  public init<CharacterView: View>(characterView: CharacterView, accentColor: HelloColor) {
    self.characterView = AnyView(characterView)
    self.accentColor = accentColor
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
//        RadialGradient(stops: [.init(color: HelloColor.dark.swiftuiColor, location: 0),
//                               //.init(color: HelloColor.dark.swiftuiColor, location: 0.1),
//                               .init(color: accentColor.swiftuiColor, location: 0.76),
//                               .init(color: accentColor.swiftuiColor, location: 1)],
//                       center: .center, startRadius: 0.25 * geometry.size.minSide,
//                       endRadius: geometry.size.minSide)
        LinearGradient(stops: [.init(color: accentColor.modify(saturation: 0.1, brightness: -0.25).swiftuiColor, location: 0),
                               .init(color: accentColor.swiftuiColor, location: 1),
                               
                               //.init(color: HelloColor.dark.swiftuiColor, location: 0.6),
                               //.init(color: accentColor.swiftuiColor, location: 0.76),
                               //.init(color: accentColor.swiftuiColor, location: 0.9),
                                ],
                       startPoint: .top,
                       endPoint: .bottom)
        //HelloColor.dark.swiftuiColor
//        Capsule(style: .continuous)
//          .stroke(AngularGradient(stops: [.init(color: HelloColor.retroApple.green.swiftuiColor, location: 0),
//                                          .init(color: HelloColor.retroApple.green.swiftuiColor, location: 0.166),
//                                          .init(color: HelloColor.retroApple.yellow.swiftuiColor, location: 0.167),
//                                          .init(color: HelloColor.retroApple.yellow.swiftuiColor, location: 0.333),
//                                          .init(color: HelloColor.retroApple.orange.swiftuiColor, location: 0.334),
//                                          .init(color: HelloColor.retroApple.orange.swiftuiColor, location: 0.5),
//                                          .init(color: HelloColor.retroApple.red.swiftuiColor, location: 0.501),
//                                          .init(color: HelloColor.retroApple.red.swiftuiColor, location: 0.666),
//                                          .init(color: HelloColor.retroApple.purple.swiftuiColor, location: 0.667),
//                                          .init(color: HelloColor.retroApple.purple.swiftuiColor, location: 0.833),
//                                          .init(color: HelloColor.retroApple.blue.swiftuiColor, location: 0.834),
//                                          .init(color: HelloColor.retroApple.blue.swiftuiColor, location: 1)],
//                                  center: .center),
//                  lineWidth: 0.016 * geometry.size.minSide)
//          .frame(width: 0.072 * geometry.size.minSide, height: 0.072 * geometry.size.minSide)
//          .padding(0.06 * geometry.size.minSide)
//          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        
//        AppIconShape()
//          .strokeBorder(accentColor.swiftuiColor,
//                  lineWidth: 0.06 * geometry.size.minSide)
//          .mask {
//            ZStack {
//              Capsule(style: .continuous)
//                .frame(width: 0.06 * geometry.size.minSide,
//                       height: 0.25 * geometry.size.minSide)
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
//              Capsule(style: .continuous)
//                .frame(width: 0.25 * geometry.size.minSide,
//                       height: 0.06 * geometry.size.minSide)
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
//              Rectangle()
//                .frame(width: 0.225 * geometry.size.minSide,
//                       height: 0.225 * geometry.size.minSide)
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
//            }
//          }
//          .padding(0.03 * geometry.size.minSide)
        
//        Capsule(style: .continuous)
//          .fill(accentColor.swiftuiColor)
//          .frame(width: 0.06 * geometry.size.minSide,
//                 height: 0.31 * geometry.size.minSide)
//          .rotationEffect(.radians(0.25 * .pi))
//          .offset(x: -0.125 * geometry.size.minSide,
//                  y: -0.005 * geometry.size.minSide)
//          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
//
//        Capsule(style: .continuous)
//          .fill(accentColor.swiftuiColor)
//          .frame(width: 0.1 * geometry.size.minSide,
//                 height: 0.2 * geometry.size.minSide)
//          .rotationEffect(.radians(0.25 * .pi))
//          .offset(x: -0.08 * geometry.size.minSide,
//                  y: -0.04 * geometry.size.minSide)
//          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        
//        Rectangle()
//          .fill(accentColor.swiftuiColor)
//          .frame(width: 1 * geometry.size.minSide,
//                 height: 0.172 * geometry.size.minSide)
//          .offset(y: 0.06 * geometry.size.height)
//
//        Rectangle()
//          .fill(accentColor.swiftuiColor)
//          .frame(width: 0.172 * geometry.size.minSide,
//                 height: 1 * geometry.size.minSide)
        
//        Rectangle()
//          .fill(HelloColor.dark.swiftuiColor)
//          .frame(width: 0.7 * geometry.size.minSide,
//                 height: 0.172 * geometry.size.minSide)
//          .offset(y: 0.06 * geometry.size.height)
          //.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        
//        AppIconShape()
//          .strokeBorder(lineWidth: 0.03 * geometry.size.minSide)
//          .foregroundStyle(LinearGradient(stops: [.init(color: HelloColor.dark.swiftuiColor.opacity(0), location: 0),
//                                                  .init(color: HelloColor.dark.swiftuiColor.opacity(0), location: 0.72),
//                                                  .init(color: accentColor.swiftuiColor, location: 0.9),
//                                                  .init(color: accentColor.swiftuiColor, location: 1)],
//                                          startPoint: .bottomTrailing,
//                                          endPoint: .topLeading))
          //.padding(0.03 * geometry.size.minSide)
        
//        Capsule(style: .continuous)
//          .fill(accentColor.swiftuiColor)
//          .frame(width: 0.4 * geometry.size.minSide, height: 0.03 * geometry.size.minSide)
//          .padding(.bottom, 0.03 * geometry.size.minSide)
//          .frame(height: geometry.size.minSide, alignment: .bottom)
        
//          .shadow(color: accentColor.swiftuiColor, radius: 0.01 * geometry.size.minSide)
//          .shadow(color: accentColor.swiftuiColor, radius: 0.025 * geometry.size.minSide)
//          //.frame(height: 0.74 * geometry.size.minSide)
//        StandardIconBottomCurve()
//          .fill(accentColor.swiftuiColor)
//        VStack(spacing: 0) {
//          HelloColor.dark.swiftuiColor
//            .frame(height: 0.74 * geometry.size.minSide)
//          accentColor.swiftuiColor
//        }
        
        characterView
          .frame(width: geometry.size.minSide, height: geometry.size.minSide)
      }.frame(width: geometry.size.width, height: geometry.size.height)
    }
  }
}
