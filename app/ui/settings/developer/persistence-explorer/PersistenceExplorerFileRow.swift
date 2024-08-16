#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct PersistenceExplorerFileRow: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(PagerModel.self) private var pagerModel
  @Environment(PersistenceExplorerFileModel.self) private var fileModel
  
  var file: PersistenceFileSnapshotType
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, action: {
      switch file {
      case .file(let file):
        windowModel.presentSheet {
          PersistenceExplorerFileSheet(file: file)
            .environment(fileModel)
        }
      case.folder(let folder):
        pagerModel.push(id: folder.id, name: folder.name) {
          PersistenceExplorerSettingsPage(snapshot: folder)
            .environment(fileModel)
        }
      }
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Group {
            switch file {
            case .file(let file):
              Image(systemName: ContentType.inferFrom(fileExtension: file.url.pathExtension).iconName)
            case .folder(let folder):
              ZStack {
                Image(systemName: "folder.fill")
                if !folder.files.isEmpty {
                  Text(String(folder.files.count))
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .monospaced()
                    .foregroundStyle(theme.surface.backgroundColor)
                    .fixedSize()
                    .frame(width: 30, height: 30)
                    .offset(y: 3)
                }
              }
            }
          }.font(.system(size: 20, weight: .regular, design: .rounded))
            .frame(width: 30)
            .padding(.trailing, 2)
          Text(file.name)
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .lineLimit(1)
            .truncationMode(.middle)
          
          Spacer(minLength: 0)
          Text(file.size.string())
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .lineLimit(1)
          if case .folder = file {
            Image(systemName: "chevron.right")
              .font(.system(size: 16, weight: .regular, design: .rounded))
          }
        }
      }.frame(height: 56)
    }
  }
}
#endif
