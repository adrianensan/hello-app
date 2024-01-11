#if os(iOS)
import SwiftUI

import HelloCore

public struct HelloCloseButton: View {
  
  @Environment(\.theme) private var helloTheme
  @Environment(HelloDismissModel.self) private var dismissModel
  
  public init() { }
  
  public var body: some View {
    ZStack {
      ZStack {
        Circle()
          .trim(from: 0, to: dismissModel.dismissProgress)
          .stroke(helloTheme.floating.foreground.primary.color,
                  style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
          .rotationEffect(.radians(-0.5 * .pi))
          .opacity(sqrt(dismissModel.dismissProgress))
          .opacity(dismissModel.dismissProgress == 1 ? 0 : 1)
        
        Circle()
          .fill(helloTheme.floating.foreground.primary.color)
          .opacity(dismissModel.dismissProgress == 1 ? 1 : 0)
          .animation(.easeInOut(duration: 0.025), value: dismissModel.dismissProgress)
          .frame(width: dismissModel.dismissProgress == 1 ? 16 : 8,
                 height: dismissModel.dismissProgress == 1 ? 16 : 8)
          .animation(.easeInOut(duration: 0.2), value: dismissModel.dismissProgress)
      }.frame(width: 8, height: 8)
        .padding(.top, 8)
        .offset(y: min(1, 2 * dismissModel.dismissProgress) * 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      
      ZStack {
        Capsule(style: .continuous)
          .fill(helloTheme.floating.foreground.primary.color)
          .frame(width: 3, height: 26 - min(1, 2 * dismissModel.dismissProgress) * 13)
          .frame(height: 26, alignment: .top)
          .rotationEffect(.radians(0.25 * .pi))
        
        Capsule(style: .continuous)
          .fill(helloTheme.floating.foreground.primary.color)
          .frame(width: 3, height: 26 - min(1, 2 * dismissModel.dismissProgress) * 13)
          .frame(height: 26, alignment: .top)
          .rotationEffect(.radians(-0.25 * .pi))
        
        Capsule(style: .continuous)
          .fill(helloTheme.floating.foreground.primary.color)
          .frame(width: 3, height: dismissModel.dismissProgress * 40)
          .frame(width: 1, height: 1, alignment: .bottom)
      }.frame(width: 44, height: 44)
        .offset(y: min(1, 2 * dismissModel.dismissProgress) * 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }.frame(width: 44, height: 44 + dismissModel.dismissProgress * 40)
      .background(helloTheme.floating.backgroundView(for: Capsule(style: .continuous)))
      .animation(.interactive, value: dismissModel.dismissProgress)
  }
}
#endif
