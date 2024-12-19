#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct HelloSettingsCopyrightSection: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(HelloPagerModel.self) private var pagerModel
  
  @State private var enterCodeModel = HelloEnterCodeModel()
  
  public var body: some View {
    VStack(spacing: 0) {
      HelloLogo()
        .frame(width: 80, height: 80)
        .readFrame { enterCodeModel.logoFrame = $0 }
        .foregroundStyle(theme.foreground.quaternary.style)
        .padding(.top, 8)
        .clickable()
        .onTapGesture {
          enterCodeModel.windowModel = windowModel
          enterCodeModel.pagerModel = pagerModel
          enterCodeModel.click()
        }
    }.foregroundStyle(theme.foreground.tertiary.style)
  }
}
#endif
