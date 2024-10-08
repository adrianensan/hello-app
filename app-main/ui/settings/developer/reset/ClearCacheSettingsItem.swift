#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

import HelloCore
import HelloApp

struct ClearCacheSettingsItem: View {
  
  @Environment(HelloWindowModel.self) private var windowModel
  
  var body: some View {
    HelloButton(clickStyle: .highlight, action: {
      windowModel.show(alert: HelloAlertConfig(
        title: "Clear Cache",
        message: "Clear things such as downloaded images",
        firstButton: .cancel,
        secondButton: .init(
          name: "Clear",
          action: {
            try Persistence.wipeFiles(in: .cache)
            try Persistence.wipeFiles(in: .temporary)
          },
          isDestructive: true)))
    }) {
      HelloNavigationRow(icon: "trash", name: "Clear Cache", actionIcon: .arrow)
    }
  }
}
#endif
