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
                  try await Persistence.nuke()
                  UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                  Task {
                    try await Task.sleep(seconds: 1)
                    exit(0)
                  }
                },
                isDestructive: true)))
          },
          isDestructive: true)))
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Image(systemName: "trash")
            .font(.system(size: 20, weight: .regular))
            .frame(width: 32, height: 32)
          
          Text("Delete Everything")
            .font(.system(size: 16, weight: .regular))
          Spacer(minLength: 0)
          Image(systemName: "chevron.right")
            .font(.system(size: 16, weight: .regular))
        }
      }
    }
  }
}
#endif
