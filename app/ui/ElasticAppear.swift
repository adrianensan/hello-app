import SwiftUI

public extension View {
  func elasticAppear(orderPosition: Double, isPresented: Bool, yOffset: CGFloat = 100) -> some View {
    compositingGroup()
      .offset(x: 0, y: isPresented ? 0 : yOffset)
      .opacity(isPresented ? 1 : 0)
      .animation(.spring(response: 0.8, dampingFraction: 0.9, blendDuration: 1)
                 //.speed(isPresented ? 1 : (1 + orderPosition * 0.05))
        .delay(isPresented ? orderPosition * 0.06 : 0), value: isPresented)
  }
}
