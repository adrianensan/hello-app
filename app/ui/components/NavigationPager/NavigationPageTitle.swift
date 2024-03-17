#if os(iOS)
import SwiftUI

@MainActor
public struct NavigationPageTitle: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.windowFrame) private var windowFrame
  @Environment(\.helloPagerConfig) private var config
  @Environment(HelloScrollModel.self) private var scrollModel
  
  let title: String
  
  private var isSmallSize: Bool {
    windowFrame.height <= 600
  }
  
  private var titleOffset: CGFloat {
    isSmallSize ? 0 : 72
  }
  
  public var body: some View {
    Text(title)
      .offset(y: 0.5 * (min(titleOffset, max(scrollModel.scrollOffset + titleOffset, 0)) + (isSmallSize ? 1 : 0.5) * scrollModel.overscroll))
      .scaleEffect(1 + 0.004 * (min(titleOffset, max(scrollModel.scrollOffset + titleOffset, 0)) + 0.2 * scrollModel.overscroll))
  }
}
#endif