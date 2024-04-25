#if os(iOS)
import SwiftUI

import HelloCore

@MainActor
public struct HelloCloseButton: View {
  
  @Environment(\.theme) private var helloTheme
  @Environment(HelloScrollModel.self) private var scrollModel
  
  private var onDismiss: @MainActor () -> Void
  
  public init(onDismiss: @MainActor @escaping () -> Void) {
    self.onDismiss = onDismiss
  }
  
  private var dismissProgress: CGFloat { scrollModel.dismissProgress }
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: { onDismiss() }) {
      ZStack {
        ZStack {
          Circle()
            .trim(from: 0, to: dismissProgress)
            .stroke(helloTheme.floating.foreground.primary.color,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .rotationEffect(.radians(-0.5 * .pi))
            .opacity(sqrt(dismissProgress))
            .opacity(dismissProgress == 1 ? 0 : 1)
          
          Circle()
            .fill(helloTheme.floating.foreground.primary.color)
            .opacity(dismissProgress == 1 ? 1 : 0)
            .animation(.easeInOut(duration: 0.025), value: dismissProgress)
            .frame(width: dismissProgress == 1 ? 16 : 8,
                   height: dismissProgress == 1 ? 16 : 8)
            .animation(.easeInOut(duration: 0.2), value: dismissProgress)
        }.frame(width: 8, height: 8)
          .padding(.top, 8)
          .offset(y: min(1, 5 * dismissProgress) * 6)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        ZStack {
          Capsule(style: .continuous)
            .fill(helloTheme.floating.foreground.primary.color)
            .frame(width: 3, height: 20 - min(1, 5 * dismissProgress) * 10)
            .frame(height: 20, alignment: .top)
            .rotationEffect(.radians(0.25 * .pi))
          
          Capsule(style: .continuous)
            .fill(helloTheme.floating.foreground.primary.color)
            .frame(width: 3, height: 20 - min(1, 5 * dismissProgress) * 10)
            .frame(height: 20, alignment: .top)
            .rotationEffect(.radians(-0.25 * .pi))
          
          Capsule(style: .continuous)
            .fill(helloTheme.floating.foreground.primary.color)
            .frame(width: 3, height: dismissProgress * 40)
            .frame(width: 1, height: 1, alignment: .bottom)
        }.frame(width: 40, height: 40)
          .offset(y: min(1, 5 * dismissProgress) * 10)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
      }.frame(width: 40, height: 40 + dismissProgress * 40)
        .background(helloTheme.floating.backgroundView(for: Capsule(style: .continuous)))
        .padding(2)
        .frame(width: 44, height: 44, alignment: .top)
        .animation(.interactive, value: dismissProgress)
    }.onChange(of: scrollModel.dismissProgress) {
      if scrollModel.dismissProgress == 1 {
        ButtonHaptics.buttonFeedback()
        onDismiss()
      }
    }
  }
}
#endif
