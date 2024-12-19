#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct AppIconSettingsRow: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloPagerModel.self) private var pagerModel
  
  @State private var appIconModel: AppIconModel
  
  public init(_ appIconConfig: some HelloAppIconConfig) {
    _appIconModel = State(initialValue: AppIconModel(appIconConfig: appIconConfig))
  }
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, action: {
      pagerModel.push(name: "App Icon") { AppIconSettingsPage().environment(appIconModel) }
    }) {
      HelloNavigationRow(icon: "app", name: "App Icon", actionIcon: .arrow) {
        AppIconView(icon: appIconModel.currentIcon)
          .frame(width: 36, height: 36)
          .frame(height: 20)
      }
    }.onAppear { appIconModel.setup() }
  }
}
#endif
