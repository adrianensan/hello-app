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

#if os(iOS)
@MainActor
public struct BackButton: View {
  
  @Environment(\.theme) private var theme
  @Environment(BackProgressModel.self) private var backProgressModel
  
  var rotationInterval: CGFloat = 0.6
  var backText: String?
  
  var rotationIntervalProgress: CGFloat {
    max(0, min(1, backProgressModel.backProgress / rotationInterval))
  }
  
  public init(backText: String? = nil) {
    self.backText = backText
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
        .padding(-4)
      
      if let backText {
        Text(backText)
          .font(.system(size: 14, weight: .semibold, design: .rounded))
          .foregroundStyle(theme.floating.foreground.primary.style)
          .fixedSize()
          .padding(.trailing, 10)
      }
    }.background {
      ZStack {
        Capsule(style: .continuous)
          .fill(.thinMaterial)
          .opacity(min(1, (backProgressModel.backProgress * backProgressModel.backProgress / 0.1)))
        ClearClickableView()
      }
        //        Capsule(style: .continuous)
        //          .fill(theme.textPrimary.swiftuiColor)
        //          .frame(width: 44 + backProgressModel.backProgress * 36, height: 44, alignment: .leading)
      }
      .padding(4)
      .animation(.interactive, value: backProgressModel.backProgress)
      .hoverEffect(.lift)
  }
}
#endif
