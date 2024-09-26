import SwiftUI

import HelloCore
import HelloApp

public struct InstagramAppIconView: View {
  
  private let icon: AnyView
  
  public init(icon: some View) {
    self.icon = AnyView(icon)
  }
  
  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        RadialGradient(gradient: Gradient(colors: [Color(.sRGB, red: 0.98, green: 0.86, blue: 0.52, opacity: 1),
                                                   Color(.sRGB, red: 0.92, green: 0.52, blue: 0.23, opacity: 1),
                                                   Color(.sRGB, red: 0.77, green: 0.23, blue: 0.46, opacity: 1),
                                                   Color(.sRGB, red: 0.54, green: 0.22, blue: 0.72, opacity: 1),
                                                   Color(.sRGB, red: 0.32, green: 0.36, blue: 0.81, opacity: 1)]),
                       center: .init(x: 0.2, y: 1), startRadius: 0, endRadius: 1.4 * geometry.size.width)
        Color.white
          .mask(icon)
      }.frame(width: geometry.size.width, height: geometry.size.height)
        .background(.white)
    }
  }
}
