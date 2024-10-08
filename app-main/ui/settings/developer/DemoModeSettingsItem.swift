#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

import HelloCore
import HelloApp

extension PersistenceMode: HelloPickerItem {}

struct DemoModeSettingsItem: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  
  @Persistent(.persistenceMode) private var persistenceMode
  
  private var actionName: String { persistenceMode == .demo ? "Disable" : "Enable" }
  
  func title(for persistenceMode: PersistenceMode) -> String {
    switch persistenceMode {
    case .normal: "Disable \(self.persistenceMode.name) Mode"
    case .demo: "Enable \(persistenceMode.name) Mode"
    case .freshInstall: "Enable \(persistenceMode.name) Mode"
    }
  }
  
  var body: some View {
    HelloNavigationRow(icon: "play.circle", name: "Persistence Mode") {
      HelloPicker(selected: persistenceMode,
                  options: PersistenceMode.allCases,
                  onChange: { newPersistenceMode in
        guard persistenceMode != newPersistenceMode else { return }
        windowModel.show(alert: HelloAlertConfig(
          title: title(for: newPersistenceMode),
          message: "\(AppInfo.displayName) will close immediately",
          firstButton: .cancel,
          secondButton: .init(
            name: actionName,
            action: {
              await Persistence.save(newPersistenceMode, for: .persistenceMode)
              exitGracefully()
            },
            isDestructive: newPersistenceMode != .normal)))
      })
    }
  }
}
#endif
