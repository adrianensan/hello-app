import SwiftUI

import HelloCore

public struct PointingArrow: View {
  
  public enum Direction: String, Sendable  {
    case up
    case down
    
    var vector: CGPoint {
      switch self {
      case .up: CGPoint(x: 0, y: 1)
      case .down: CGPoint(x: 0, y: -1)
      }
    }
    
    var alignment: Alignment {
      switch self {
      case .up: .top
      case .down: .bottom
      }
    }
  }
  
  @Environment(\.isEnabled) private var isEnabled
  
  @State private var hasAppeared: Bool = false
  @State private var isAnimating: Bool = false
  
  private var direction: Direction
  
  public init(direction: Direction) {
    self.direction = direction
  }
  
  public var body: some View {
    Image(systemName: "arrow.\(direction.rawValue)")
      .opacity(hasAppeared ? 1 : 0)
      .animation(hasAppeared ? .easeInOut(duration: 3) : nil, value: hasAppeared)
      .fixedSize()
      .frame(width: 1, height: 1, alignment: direction.alignment)
      .offset(y: direction.vector.y * (isAnimating ? 16 : 0))
      .animation(isAnimating ? .easeInOut(duration: 0.5).repeatForever() : nil, value: isAnimating)
      .onChange(of: isEnabled, initial: true) {
        if isEnabled {
          Task {
            try? await Task.sleep(seconds: 0.5)
            hasAppeared = true
            try? await Task.sleepForOneFrame()
            isAnimating = true
          }
        } else {
          isAnimating = false
          hasAppeared = false
        }
      }.transaction { $0.animation = nil }
  }
}
