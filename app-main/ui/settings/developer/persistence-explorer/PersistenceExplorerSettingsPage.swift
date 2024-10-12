#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct PersistenceExplorerSettingsPage: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(PersistenceExplorerFileModel.self) private var fileModel
  
  init() {}
  
  public var body: some View {
    NavigationPage(title: "Persistence", showScrollIndicators: true) {
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
}
#endif