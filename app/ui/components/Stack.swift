import SwiftUI

import HelloCore

public struct Stack<Content: View>: View {
  
  var orientation: Orientation
  var spacing: CGFloat
  var content: Content
  
  public init(orientation: Orientation,
              spacing: CGFloat = 0,
              @ViewBuilder content: () -> Content) {
    self.orientation = orientation
    self.spacing = spacing
    self.content = content()
  }
  
  public var body: some View {
    switch orientation {
    case .horizontal:
      HStack(spacing: spacing) {
        content
      }
    case .vertical:
      VStack(spacing: spacing) {
        content
      }
    }
  }
}
