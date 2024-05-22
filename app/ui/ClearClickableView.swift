import SwiftUI

import HelloCore

struct ClickableViewModifier: ViewModifier {
  
  @Persistent(.showDebugBorders) private var showDebugBorders
  
  func body(content: Content) -> some View {
    if showDebugBorders {
      content
        .overlay(ClearClickableView())
    } else {
      content
        .background(ClearClickableView())
    }
  }
}

@MainActor
public struct ClearClickableView: View {
  
  @Persistent(.showDebugBorders) private var showDebugBorders
  
  public init() {}
  
  public var body: some View {
    if showDebugBorders {
      Color.clear.contentShape(.interaction, Rectangle())
        .overlay {
          Rectangle().strokeBorder(HelloColor.retroApple.red.swiftuiColor, lineWidth: 1)
        }
    } else {
      Color.clear.contentShape(.interaction, Rectangle())
    }
  }
}

@MainActor
public extension View {
  func clickable() -> some View {
    modifier(ClickableViewModifier())
  }
}
