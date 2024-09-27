import SwiftUI

public struct NavigationPageTitle: View {
  
  @Environment(\.windowFrame) private var windowFrame
  @Environment(\.helloPagerConfig) private var config
  @Environment(HelloScrollModel.self) private var scrollModel
  
  let title: String
  
  private var isSmallSize: Bool {
    windowFrame.height <= 600
  }
  
  private var titleOffset: CGFloat {
    config.overrideNavBarTitleScrollsDown == false || isSmallSize ? 0 : -scrollModel.effectiveScrollThreshold
  }
  
  private var progress: CGFloat { titleOffset > 0 ? (titleOffset + scrollModel.scrollOffset) / titleOffset : 0 }
  
  private var scaleProgress: CGFloat {
    var adjustedProgress = max(0, progress)
    if adjustedProgress > 1 {
      adjustedProgress = sqrt(adjustedProgress)
    }
    return adjustedProgress
  }
  
  private var offsetProgress: CGFloat {
    var adjustedProgress = max(0, progress)
    if adjustedProgress > 1 {
      adjustedProgress = 1 + (0.8 * (adjustedProgress - 1))
    }
    return adjustedProgress
  }
  
  public var body: some View {
    Text(title)
      .minimumScaleFactor(0.8)
      .lineLimit(1)
      .padding(.horizontal, 36)
      .scaleEffect(1 + 0.4 * scaleProgress)
      .offset(y: max(0, offsetProgress * 0.8 * titleOffset))
  }
}
