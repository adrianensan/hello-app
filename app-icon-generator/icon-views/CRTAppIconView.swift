import SwiftUI

import HelloCore
import HelloApp

public struct CRTAppIconView: View {
  
  private let icon: AnyView
  
  public init(icon: some View) {
    self.icon = AnyView(icon)
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        HelloColor.neonGreen.swiftuiColor
          .mask(icon)
        
        let rowHeight = geometry.size.height / 34
        Path { path in
          for row in 0...Int(geometry.size.height / rowHeight) {
            path.move(to: CGPoint(x: 0, y: CGFloat(row) * rowHeight))
            path.addLine(to: CGPoint(x: geometry.size.width, y: CGFloat(row) * rowHeight))
          }
          path.move(to: CGPoint(x: 0, y: 0))
        }.stroke(.black, lineWidth: 0.5 * rowHeight)
      }.frame(width: geometry.size.width, height: geometry.size.height)
        .background(.black)
    }
  }
}
