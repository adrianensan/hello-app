#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct NewAppIconSettingsRow: View {
  
  @Environment(\.theme) private var theme
  @Environment(PagerModel.self) private var pagerModel
  
  @State private var appIconModel: NewAppIconModel
  
  public init(_ appIconConfig: some HelloAppIconConfig) {
    _appIconModel = State(initialValue: NewAppIconModel(appIconConfig: appIconConfig))
  }
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      pagerModel.push(name: "App Icon") { NewAppIconSettingsPage().environment(appIconModel) }
    }) {
      HelloNavigationRow(icon: "app", name: "App Icon", actionIcon: .arrow) {
        NewAppIconView(icon: appIconModel.currentIcon)
          .frame(width: 36, height: 36)
          .frame(height: 20)
      }
    }.onAppear { appIconModel.setup() }
  }
}
#endif
