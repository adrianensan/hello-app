import SwiftUI

import HelloCore

public struct AppIconSettingsRow<AppIcon: IOSAppIcon>: View {
  
  @Environment(PagerModel.self) private var pagerModel
  
  @State private var appIconModel: AppIconModel<AppIcon> = AppIconModel()
  
  public init() {
    
  }
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      pagerModel.push { AppIconSettingsPage<AppIcon>().environment(appIconModel) }
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Image(systemName: "app")
            .font(.system(size: 20, weight: .regular))
            .frame(width: 32, height: 32)
          
          Text("App Icon")
            .font(.system(size: 16, weight: .regular))
          Spacer(minLength: 0)
          appIconModel.currentIcon.view.flattenedView
            .dimForTheme()
            .frame(width: 32, height: 32)
            .clipShape(AppIconShape())
          Image(systemName: "chevron.right")
            .font(.system(size: 16, weight: .regular))
        }
      }
    }
  }
}
