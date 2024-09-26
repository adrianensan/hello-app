import SwiftUI

import HelloCore

struct MiniProgressViewMask: Shape {
  
  let progress: Double
  
  func path(in rect: CGRect) -> Path {
    Path() +& {
      $0.addArc(center: rect.center,
                radius: rect.size.diagonal,
                startAngle: Angle(radians: -0.5 * .pi),
                endAngle: Angle(radians: -0.5 * .pi + progress * 2 * .pi),
                clockwise: false)
      $0.addLine(to: rect.center)
      $0.closeSubpath()
    }
  }
}

public struct SquircleProgressView: View {
  
  @Environment(\.colorScheme) var colorScheme
  
  var progress: CGFloat
  var lineWidth: Double
  
  public init(progress: CGFloat,
              lineWidth: Double = 3) {
    self.progress = progress
    self.lineWidth = lineWidth
  }
  
  private var opacity: CGFloat {
    switch colorScheme {
    case .dark: 0.22
    default: 0.16
    }
  }
  
  public var body: some View {
    ZStack {
      Capsule(style: .continuous)
        .stroke(lineWidth: lineWidth)
        .opacity(opacity)
      Capsule(style: .continuous)
        .stroke(lineWidth: lineWidth)
        .clipShape(MiniProgressViewMask(progress: progress))
    }
  }
}
