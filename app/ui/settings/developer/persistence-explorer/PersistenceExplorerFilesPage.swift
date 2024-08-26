#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct PersistenceExplorerFilesPage: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(PersistenceExplorerFileModel.self) private var fileModel
  
  private var snapshot: PersistenceFolderSnapshot
  
  @State private var sortedFiles: [PersistenceFileSnapshotType] = []
  @NonObservedState private var sortButtonFrame: CGRect = .zero
  
  init(snapshot: PersistenceFolderSnapshot) {
    self.snapshot = snapshot
  }
  
  public var body: some View {
    NavigationPage(showScrollIndicators: true, navBarContent: {
      HelloButton(action: {
        windowModel.showPopup {
          HelloMenu(
            position: sortButtonFrame.topTrailing,
            anchor: .topTrailing,
            items: PersistenceExplorerFileSorting.allCases.map { sortOption in
              HelloMenuItem(name: sortOption.name, icon: sortOption.iconName) {
                fileModel.sorting = sortOption
              }
            })
        }
      }) {
        Image(systemName: "arrow.up.arrow.down")
          .font(.system(size: 20, weight: .regular))
          .foregroundStyle(theme.foreground.primary.style)
          .frame(width: 44, height: 44)
          .clickable()
      }.readFrame(to: $sortButtonFrame)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }) {
      VStack(spacing: 32) {
        VStack(spacing: 8) {
          Text(snapshot.name)
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(theme.foreground.primary.style)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
          Text("\(sortedFiles.count) Files")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(theme.foreground.tertiary.style)
        }
        HelloSection {
          ForEach(sortedFiles) { file in
            PersistenceExplorerFileRow(file: file)
          }
        }
      }
    }.onChange(of: fileModel.sorting, initial: true) {
      sortedFiles = fileModel.sort(files: snapshot.files)
    }.onChange(of: fileModel.deletedFiles) {
      sortedFiles = fileModel.sort(files: snapshot.files)
    }
  }
}
#endif
