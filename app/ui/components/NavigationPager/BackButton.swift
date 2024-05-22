import SwiftUI
import Observation

extension Animation {
  public static var interactive: Animation {
    .spring(response: 0.15, dampingFraction: 0.85, blendDuration: 0)
  }
}

@MainActor
@Observable
public class BackProgressModel {
  
  public var backProgress: CGFloat = 0
}

@MainActor
public struct BackButton: View {
  
  @Environment(\.theme) private var theme
  @Environment(PagerModel.self) var pagerModel
  @Environment(BackProgressModel.self) private var backProgressModel
  
  var rotationInterval: CGFloat = 0.6
  
  var rotationIntervalProgress: CGFloat {
    max(0, min(1, backProgressModel.backProgress / rotationInterval))
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
          .frame(width: backProgressModel.backProgress * 36 + (rotationIntervalProgress * 10), height: 3)
          .offset(x: rotationIntervalProgress * 10)
          .frame(width: 1, height: 1, alignment: .trailing)
      }.frame(width: 44, height: 44)
        .offset(x: -6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .frame(width: 44 + backProgressModel.backProgress * 36, height: 44)
        .padding(.leading, -4)
      
      let effectiveBackProgress: CGFloat = pagerModel.viewDepth > 1 && pagerModel.viewDepth != pagerModel.viewStack.count ? 1 : 0
      VStack(alignment: .leading, spacing: 0) {
        ForEach(Array(pagerModel.viewStack.dropLast().enumerated()), id: \.element.id) { index, page in
          let distance: CGFloat = CGFloat(pagerModel.viewStack.count - index - 2) - effectiveBackProgress
          Text(page.name ?? "Back")
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(theme.floating.foreground.primary.style)
            .fixedSize()
            .frame(height: 15)
            .opacity(1 - 0.6 * abs(distance))
            .scaleEffect(1 - 0.2 * abs(distance), anchor: .leading)
        }
      }.frame(height: 15, alignment: .bottom)
        .offset(y: 15 * effectiveBackProgress)
        .padding(.trailing, 12)
        .animation(.pageAnimation, value: pagerModel.viewStack.count)
        .animation(.pageAnimation, value: pagerModel.viewDepth)
    }.background {
      ZStack {
        Capsule(style: .continuous)
          .fill(.thinMaterial)
          .opacity(min(1, (backProgressModel.backProgress / 0.2)))
      }
        //        Capsule(style: .continuous)
        //          .fill(theme.textPrimary.swiftuiColor)
        //          .frame(width: 44 + backProgressModel.backProgress * 36, height: 44, alignment: .leading)
      }
      .animation(backProgressModel.backProgress == 0 ? .pageAnimation : .interactive, value: backProgressModel.backProgress)
//      .hoverEffect(.lift)
  }
}
