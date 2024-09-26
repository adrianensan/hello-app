#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

import HelloCore
import HelloApp

public struct PersistenceExplorerSettingsRow: View {
  
  @Environment(PagerModel.self) private var pagerModel
  
  @State private var model = PersistenceExplorerFileModel()
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      if let files = model.files {
        pagerModel.push(id: files.id, name: "Root") {
          PersistenceExplorerSettingsPage()
            .environment(model)
        }
      }
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Image(systemName: "folder")
            .font(.system(size: 20, weight: .regular))
            .frame(width: 32, height: 32)
          
          Text("Persistence Explorer")
            .font(.system(size: 16, weight: .regular))
          Spacer(minLength: 0)
          if let files = model.files {
            Text(files.sizeOnDisk.string())
              .font(.system(size: 16, weight: .regular))
          }
          Image(systemName: "chevron.right")
            .font(.system(size: 16, weight: .regular))
        }
      }
    }
  }
}
#endif
