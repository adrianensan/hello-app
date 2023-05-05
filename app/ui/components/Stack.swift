import SwiftUI

import HelloCore

public struct Stack<Content: View>: View {
  
  var orientation: Orientation
  var alignment: Alignment
  var spacing: CGFloat
  var isReversed: Bool
  var content: Content
  
  public init(orientation: Orientation,
              alignment: Alignment = .center,
              spacing: CGFloat = 0,
              isReversed: Bool = false,
              @ViewBuilder content: () -> Content) {
    self.orientation = orientation
    self.alignment = alignment
    self.spacing = spacing
    self.isReversed = isReversed
    self.content = content()
  }
  
  public var body: some View {
    switch orientation {
    case .horizontal:
      HStack(alignment: alignment.vertical, spacing: spacing) {
        content
          .environment(\.layoutDirection, .leftToRight)
      }.environment(\.layoutDirection, isReversed ? .rightToLeft : .leftToRight)
    case .vertical:
      VStack(alignment: alignment.horizontal, spacing: spacing) {
        content
          .environment(\.layoutDirection, .leftToRight)
      }.environment(\.layoutDirection, isReversed ? .rightToLeft : .leftToRight)
    }
  }
}
