import SwiftUI

import HelloCore

public struct LoadingSpinner: View {
  
  @State private var animateIn: Bool = false
  
  public init() {}
  
  public var body: some View {
    GeometryReader { geometry in
      Circle()
        .strokeBorder(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
        .frame(width: geometry.size.minSide, height: geometry.size.minSide)
        .mask(
          AngularGradient(gradient: Gradient(colors: [.white.opacity(0), .white]), center: .center)
            .rotationEffect(animateIn ? .radians(2 * .pi) : .zero)
            .animation(.linear(duration: 0.75).repeatForever(autoreverses: false), value: animateIn)
        )
    }.onAppear { animateIn = true }
  }
}

struct LoadingView: View {
  
  @State var animateIn: Bool = false
  
  var body: some View {
    LoadingSpinner()
      //.foregroundColor(tbTheme.textPrimary.swiftuiColor)
      .frame(width: 44, height: 44)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.black.opacity(0.4))
      .onAppear { animateIn = true }
  }
}
