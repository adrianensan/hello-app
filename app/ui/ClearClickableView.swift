import SwiftUI

import HelloCore

struct ClickableViewModifier: ViewModifier {
  
  private var debugModel: DebugModel = .main
  
  func body(content: Content) -> some View {
    if debugModel.showBorders {
      content
        .overlay(Rectangle().strokeBorder(HelloColor.retroApple.red.swiftuiColor, lineWidth: 1))
    } else {
      content
        .background(Color.clear.contentShape(.interaction, .rect))
    }
  }
}

public struct ClearClickableView: View {
  
  private var debugModel: DebugModel = .main
  
  public init() {}
  
  public var body: some View {
    if debugModel.showBorders {
      Color.clear.contentShape(.interaction, .rect)
        .overlay {
          Rectangle().strokeBorder(HelloColor.retroApple.red.swiftuiColor, lineWidth: 1)
        }
    } else {
      Color.clear.contentShape(.interaction, .rect)
    }
  }
}

@MainActor
public extension View {
  func clickable() -> some View {
    modifier(ClickableViewModifier())
  }
}
