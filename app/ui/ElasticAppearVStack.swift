import SwiftUI

import HelloCore

public struct ElasticAppearContent<Content: View>: View {
  
  @Environment(\.hasAppeared) private var hasAppeared
  
  @ViewBuilder private var content: @MainActor () -> Content
  
  @State private var isVisible: Bool = false
  
  public init(@ViewBuilder content: @escaping @MainActor () -> Content) {
    self.content = content
  }
  
  public var body: some View {
    var i: Double = -1
    ForEach(subviews: content()) { subview in
      i += 1
      return subview
        .compositingGroup()
        .offset(y: isVisible ? 0 : 160 + (40 * i))
        .opacity(isVisible ? 1 : 1)
        .animation(.dampSpring.delay(i * 0.02), value: isVisible)
    }.onChange(of: hasAppeared, initial: true) {
      if hasAppeared {
        Task {
          try? await Task.sleepForABit()
          isVisible = true
        }
      }
    }
  }
}
