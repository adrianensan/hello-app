#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

import HelloCore
import HelloApp

struct DemoModeSettingsItem: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  
  @Persistent(.isDemoMode) private var isDemoMode
  
  private var actionName: String { isDemoMode ? "Disable" : "Enable" }
  
  var body: some View {
    HelloButton(clickStyle: .highlight, action: {
      windowModel.show(alert: HelloAlertConfig(
        title: "\(actionName) Demo Mode",
        message: "\(AppInfo.displayName) will close immediately",
        firstButton: .cancel,
        secondButton: .init(
          name: actionName,
          action: {
            UserDefaults.standard.set(!isDemoMode, forKey: "is-demo-mode")
            exitGracefully()
          },
          isDestructive: true)))
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Image(systemName: isDemoMode ? "xmark" : "play.circle")
            .font(.system(size: 20, weight: .regular))
            .frame(width: 32, height: 32)
          
          Text("\(actionName) Demo Mode")
            .font(.system(size: 16, weight: .regular))
          Spacer(minLength: 0)
        }
      }
    }
  }
}
#endif
