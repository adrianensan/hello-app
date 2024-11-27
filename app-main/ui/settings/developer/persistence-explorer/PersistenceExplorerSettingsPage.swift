#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct PersistenceExplorerSettingsPage: View {
  
  init() {}
  
  public var body: some View {
    HelloPage(title: "Persistence", showScrollIndicators: true) {
      PersistenceExplorerSettingsPageContent()
    }
  }
}

struct PersistenceExplorerSettingsPageContent: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(PersistenceExplorerFileModel.self) private var fileModel
  
  init() {}
  
  public var body: some View {
    VStack(spacing: 32) {
      if let bundleSnapshot = fileModel.bundleSnapshot {
        HelloSection(title: "BUNDLE") {
          PersistenceExplorerFileRow(file: bundleSnapshot)
        }
      }
      if let files = fileModel.files {
        HelloSection(title: "FILES") {
          ForEach(files.files) { file in
            PersistenceExplorerFileRow(file: file)
          }
        }
      }
      
      HelloSection(title: "DEFAULTS") {
        ForEach(fileModel.userDefaults) { userDefaults in
          PersistenceExplorerUserDefaultsRow(userDefaults: userDefaults)
        }
      }
    }
  }
}
#endif
