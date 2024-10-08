#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct AppIconSettingsRow<AppIcon: BaseAppIcon>: View {
  
  @Environment(\.theme) private var theme
  @Environment(PagerModel.self) private var pagerModel
  
  @State private var appIconModel: AppIconModel<AppIcon> = AppIconModel()
  
  public init() {}
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      pagerModel.push(name: "App Icon") { AppIconSettingsPage<AppIcon>().environment(appIconModel) }
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Image(systemName: "app")
            .font(.system(size: 20, weight: .regular))
            .frame(width: 32, height: 32)
          
          Text("App Icon")
            .font(.system(size: 16, weight: .regular))
          Spacer(minLength: 0)
          AppIconView(icon: appIconModel.currentIcon)
            .frame(width: 36, height: 36)
            .frame(height: 20)
          Image(systemName: "chevron.right")
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(theme.surface.foreground.tertiary.style)
        }
      }
    }
  }
}
#endif
