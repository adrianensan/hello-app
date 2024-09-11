#if os(iOS)
import SwiftUI

struct HelloVisualEffectsView: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  
  var body: some View {
    if windowModel.isShowingConfetti {
      ConfettiView()
        .id(windowModel.confettiID)
        .transition(.asymmetric(insertion: .opacity.animation(.linear(duration: 0)),
                                removal: .opacity.animation(.linear(duration: 0.1).delay(8))))
    }
  }
}

public extension View {
  @ViewBuilder
  func applyVisualEfects() -> some View {
    overlay(HelloVisualEffectsView())
  }
}
#endif
