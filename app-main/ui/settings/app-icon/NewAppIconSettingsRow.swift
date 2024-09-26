#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

public struct NewAppIconSettingsRow: View {
  
  @Environment(PagerModel.self) private var pagerModel
  
  @State private var appIconModel: NewAppIconModel
  
  public init(_ appIconConfig: some HelloAppIconConfig) {
    _appIconModel = State(initialValue: NewAppIconModel(appIconConfig: appIconConfig))
  }
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      pagerModel.push(name: "App Icon") { NewAppIconSettingsPage().environment(appIconModel) }
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Image(systemName: "app")
            .font(.system(size: 20, weight: .regular))
            .frame(width: 32, height: 32)
          
          Text("App Icon")
            .font(.system(size: 16, weight: .regular))
          Spacer(minLength: 0)
          NewAppIconView(icon: appIconModel.currentIcon)
            .frame(width: 36, height: 36)
            .frame(height: 20)
          Image(systemName: "chevron.right")
            .font(.system(size: 16, weight: .regular))
        }
      }
    }.onAppear { appIconModel.setup() }
  }
}
#endif
