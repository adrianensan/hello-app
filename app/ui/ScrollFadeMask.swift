import SwiftUI

import HelloCore

public struct ScrollFadeMask: View {
  
  private var orientation: Orientation
  private var topFadeAmount: CGFloat
  private var bottomFadeAmount: CGFloat
  private var topPadding: CGFloat
  private var bottomPadding: CGFloat
  private var showTop: Bool
  private var showBottom: Bool
  
  public init(orientation: Orientation = .vertical,
              topFadeAmount: CGFloat = 8,
              bottomFadeAmount: CGFloat = 8,
              topPadding: CGFloat = 0,
              bottomPadding: CGFloat = 0,
              showTop: Bool = true,
              showBottom: Bool = true) {
    self.orientation = orientation
    self.topFadeAmount = topFadeAmount
    self.bottomFadeAmount = bottomFadeAmount
    self.topPadding = topPadding
    self.bottomPadding = bottomPadding
    self.showTop = showTop
    self.showBottom = showBottom
  }
  
  public var body: some View {
    Stack(orientation: orientation, spacing: 0) {
      Color.clear.frame(width: topPadding, height: topPadding)
      if showTop {
        LinearGradient(gradient: Gradient(colors: [.clear, .black]),
                       startPoint: orientation == .vertical ? .top : .leading,
                       endPoint: orientation == .vertical ? .bottom : .trailing)
        .frame(width: orientation == .vertical ? nil : topFadeAmount,
               height: orientation == .vertical ? topFadeAmount : nil)
      }
      Color.black.frame(maxWidth: .infinity, maxHeight: .infinity)
      if showBottom {
        LinearGradient(gradient: Gradient(colors: [.black, .clear]),
                       startPoint: orientation == .vertical ? .top : .leading,
                       endPoint: orientation == .vertical ? .bottom : .trailing)
        .frame(width: orientation == .vertical ? nil : bottomFadeAmount,
               height: orientation == .vertical ? bottomFadeAmount : nil)
      }
      Color.clear.frame(width: bottomPadding, height: bottomPadding)
    }
  }
}
