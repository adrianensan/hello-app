#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct HelloEnterCodeOverlay: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(HelloEnterCodeModel.self) private var enterCodeModel
  
  @State private var hasAppeared: Bool = false
  
  public var body: some View {
    ZStack(alignment: .topLeading) {
      HelloLogo()
        .frame(width: 80, height: 80)
        .offset(x: enterCodeModel.logoFrame.minX,
                y: enterCodeModel.logoFrame.minY)
        .foregroundStyle(theme.foreground.quaternary.style)
      HelloBackgroundDimmingView()
        .opacity(enterCodeModel.presented ? 1 : 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      @Bindable var model = enterCodeModel
      VStack(spacing: 0) {
        Spacer(minLength: 0)
        Spacer(minLength: 0)
        HelloImageView(.resource(bundle: .helloAppMain, fileName: "eyes.png"))
          .frame(width: 100, height: 100)
          .padding(.bottom, 64)
        HStack(spacing: 4) {
          Image(systemName: "chevron.right")
            .font(.system(size: 32, weight: .medium))
            .foregroundStyle(theme.foreground.tertiary.style)
          
          Text(enterCodeModel.input)
            .font(.system(size: 32, weight: .medium))
            .fontDesign(.monospaced)
            .foregroundStyle(theme.foreground.primary.style)
          
          if enterCodeModel.presented {
            BlinkingCursor()
              .foregroundStyle(theme.foreground.primary.style)
          }
        }.frame(height: 60)
        Spacer(minLength: 0)
        VStack(spacing: 0) {
          theme.divider.color.swiftuiColor
            .frame(height: theme.divider.width)
          HStack(spacing: 0) {
            HelloButton(clickStyle: .highlight, action: { enterCodeModel.cancel() }) {
              Text("Cancel")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(theme.foreground.primary.style)
                .frame(height: 60)
                .frame(maxWidth: .infinity)
            }.environment(\.contentShape, AnyInsettableShape(.rect))
            theme.divider.color.swiftuiColor
              .frame(width: theme.divider.width)
            HelloButton(clickStyle: .highlight, action: { enterCodeModel.enter() }) {
              Text("Enter")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(theme.foreground.primary.style)
                .frame(height: 60)
                .frame(maxWidth: .infinity)
            }.environment(\.contentShape, AnyInsettableShape(.rect))
          }.frame(height: 60)
          theme.divider.color.swiftuiColor
            .frame(height: theme.divider.width)
          HelloKeyboard(string: $model.input)
            .compositingGroup()
            .frame(height: enterCodeModel.presented ? nil : 0, alignment: .top)
            .allowsHitTesting(enterCodeModel.allowInteraction)
        }.background(theme.backgroundView(isBaseLayer: true))
      }.opacity(enterCodeModel.presented ? 1 : 0)
    }.allowsHitTesting(enterCodeModel.presented)
      .animation(.dampSpring, value: enterCodeModel.presented)
//      .anim
  }
}
#endif
