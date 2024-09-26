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
      HelloSectionItem {
        HStack(spacing: 4) {
          Image(systemName: "trash")
            .font(.system(size: 20, weight: .regular))
            .frame(width: 32, height: 32)
          
          Text("Clear Cache")
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
