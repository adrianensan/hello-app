import SwiftUI

public struct ClearClickableView: View {
  
  public init() {}
  
  public var body: some View {
    Color.clear.contentShape(.interaction, Rectangle())
  }
}

public extension View {
  func clickable() -> some View {
    background(ClearClickableView())
  }
}
