import SwiftUI

import HelloCore
import HelloApp

public struct BlinkingCursor: View {
  
  @Environment(\.theme) private var theme
  
  @State private var isBlinking = false
  
  public var body: some View {
    Capsule(style: .continuous)
      .fill()
      .frame(width: 3, height: 24)
      .opacity(isBlinking ? 1 : 0)
      .animation(.linear(duration: 0.02).delay(0.5).repeatForever(), value: isBlinking)
      .onAppear {
        Task {
          isBlinking = true
        }
      }
  }
}
