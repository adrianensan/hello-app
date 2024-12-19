#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

import HelloCore
import HelloApp

public struct PersistenceExplorerSettingsRow: View {
  
  @Environment(HelloPagerModel.self) private var pagerModel
  
  @State private var model = PersistenceExplorerFileModel()
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, action: {
      if let files = model.files {
        pagerModel.push(id: files.id, name: "Root") {
          PersistenceExplorerSettingsPage()
            .environment(model)
        }
      }
    }) {
      HelloNavigationRow(icon: "folder", name: "Persistence Explorer", actionIcon: .arrow) {
        if let files = model.files {
          Text(files.sizeOnDisk.string())
            .font(.system(size: 16, weight: .regular))
        }
      }
    }
  }
}
#endif
