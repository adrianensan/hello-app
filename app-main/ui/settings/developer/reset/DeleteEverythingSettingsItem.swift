#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

import HelloCore
import HelloApp

struct DeleteEverythingSettingsItem: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  
  var body: some View {
    HelloButton(clickStyle: .highlight, action: {
      windowModel.show(alert: HelloAlertConfig(
        title: "Delete Everything",
        message: "Wipe all contents and files from this app. The app will function as if it was installed for the first time",
        firstButton: .cancel,
        secondButton: .init(
          name: "Delete",
          action: {
            windowModel.show(alert: HelloAlertConfig(
              title: "Are you sure",
              message: "This can not be undone, all files will be deleted. The app will close immediately",
              firstButton: .cancel,
              secondButton: .init(
                name: "Delete",
                action: {
                  await Persistence.nuke()
                  exitGracefully()
                },
                isDestructive: true)))
          },
          isDestructive: true)))
    }) {
      HelloNavigationRow(icon: "trash", name: "Delete Everything", actionIcon: .arrow)
    }
  }
}
#endif
