#if os(iOS)
import SwiftUI
import UniformTypeIdentifiers

import HelloCore
import HelloApp

public struct PersistenceExplorerSettingsRow: View {
  
  @Environment(PagerModel.self) private var pagerModel
  
  @State var model: PersistenceExplorerFileModel
  
  init(snapshot: PersistenceSnapshot) {
    _model = State(initialValue: PersistenceExplorerFileModel(files: snapshot.files))
  }
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, haptics: .click, action: {
      pagerModel.push(id: model.files.id, name: "Root") {
        PersistenceExplorerSettingsPage(snapshot: model.files)
          .environment(model)
      }
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Image(systemName: "folder")
            .font(.system(size: 20, weight: .regular, design: .rounded))
            .frame(width: 32, height: 32)
          
          Text("Persistence Explorer")
            .font(.system(size: 16, weight: .regular, design: .rounded))
          Spacer(minLength: 0)
          Text(model.files.size.string())
            .font(.system(size: 16, weight: .regular, design: .rounded))
          Image(systemName: "chevron.right")
            .font(.system(size: 16, weight: .regular, design: .rounded))
        }
      }
    }
  }
}
#endif
