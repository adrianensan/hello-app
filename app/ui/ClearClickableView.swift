import SwiftUI

import HelloCore

struct ClickableViewModifier: ViewModifier {
  
  private var debugModel: DebugModel = .main
  
  func body(content: Content) -> some View {
    if debugModel.showBorders {
      content
        .background(Color.clear.contentShape(.interaction, .rect))
        .overlay(Rectangle().strokeBorder(HelloColor.retroApple.red.swiftuiColor, lineWidth: 1)
          .allowsHitTesting(false))
    } else {
      content
        .background(Color.clear.contentShape(.interaction, .rect))
    }
  }
}

/// A transparent view that's still clickable
public struct ClearClickableView: View {
  
  private var debugModel: DebugModel = .main
  
  public init() {}
  
  public var body: some View {
    if debugModel.showBorders {
      Color.clear.contentShape(.interaction, .rect)
        .overlay {
          Rectangle().strokeBorder(HelloColor.retroApple.red.swiftuiColor, lineWidth: 1)
            .allowsHitTesting(false)
        }
    } else {
      Color.clear.contentShape(.interaction, .rect)
    }
  }
}

public extension View {
  /// Make the view's full frame clickable, even if it's transparent
  func clickable() -> some View {
    modifier(ClickableViewModifier())
  }
}
