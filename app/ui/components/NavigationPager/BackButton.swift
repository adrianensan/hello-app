import SwiftUI

extension Animation {
  public static var interactive: Animation {
    .interpolatingSpring(duration: 0.02)
//    .spring(response: 0.15, dampingFraction: 0.85, blendDuration: 0)
  }
}

@MainActor
@Observable
public class BackProgressModel {
  public var backProgress: CGFloat = 0
  public var drag: CGFloat?
  @ObservationIgnored public var backSwipeAllowance: Bool?
  
  func reset() {
    if backProgress != 0 {
      backProgress = 0
    }
    if drag != nil {
      drag = nil
    }
  }
}

public struct BackButton: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.pageID) private var pageID
  @Environment(\.viewID) private var instanceID
  @Environment(PagerModel.self) private var pagerModel
  @Environment(BackProgressModel.self) private var backProgressModel
  
  private var rotationInterval: CGFloat = 0.6
  
  private var rotationIntervalProgress: CGFloat {
    max(0, min(1, backProgress / rotationInterval))
  }
  
  private var backProgress: CGFloat {
    pagerModel.isDismissed(instanceID: instanceID ?? "") ? 1 :
      pagerModel.activePageID == pageID ? backProgressModel.backProgress : 0
  }
  
  public init() {
  }
  
  public var body: some View {
    HStack(spacing: -8) {
      ZStack {
        Capsule(style: .continuous)
          .fill()
          .frame(width: 3, height: 15)
          .frame(height: 28, alignment: .top)
          .rotationEffect(.radians((0.25 - 0.5 * rotationIntervalProgress) * .pi))
          .offset(x: rotationIntervalProgress * 10)
        
        Capsule(style: .continuous)
          .fill()
          .frame(width: 3, height: 15)
          .frame(height: 28, alignment: .bottom)
          .rotationEffect(.radians(-(0.25 - 0.5 * rotationIntervalProgress) * .pi))
          .offset(x: rotationIntervalProgress * 10)
        
        Capsule(style: .continuous)
          .fill()
          .frame(width: backProgress * 36 + (rotationIntervalProgress * 10), height: 3)
          .offset(x: rotationIntervalProgress * 10)
          .frame(width: 1, height: 1, alignment: .trailing)
      }.frame(width: 44, height: 44)
        .offset(x: -6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .frame(width: 44 + backProgress * 36, height: 44, alignment: .trailing)
        .frame(width: 44, height: 44, alignment: .leading)
        .padding(.leading, -4)
      
      Text(pagerModel.backText(for: pageID ?? "nil"))
        .font(.system(size: 14, weight: .semibold))
        .fixedSize()
        .opacity(1 - rotationIntervalProgress)
        .offset(x: 16 * rotationIntervalProgress)
        .padding(.trailing, 12)
    }.foregroundStyle(theme.header.foreground.primary.style)
//      .foregroundStyle(theme.accent.style)
      .animation(backProgress == 0 ? .pageAnimation : nil, value: backProgress)
//      .hoverEffect(.lift)
  }
}
