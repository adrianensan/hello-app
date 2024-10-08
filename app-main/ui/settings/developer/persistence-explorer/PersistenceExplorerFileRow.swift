#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct PersistenceExplorerFileRow: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(PagerModel.self) private var pagerModel
  @Environment(PersistenceExplorerFileModel.self) private var fileModel
  
  @NonObservedState private var globalFrame: CGRect = .zero
  
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
          PersistenceExplorerFilesPage(snapshot: folder)
            .environment(fileModel)
        }
      }
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Group {
            switch file {
            case .file(let file):
              switch ContentType.inferFrom(fileExtension: file.url.pathExtension).category {
              case .image:
                HelloImageView(.url(file.url.absoluteString), variant: .thumbnail(size: 80), resizeMode: .fit)
                  .clipShape(.rect(cornerRadius: 8))
              default:
                Image(systemName: ContentType.inferFrom(fileExtension: file.url.pathExtension).iconName)
              }
            case .folder(let folder):
              ZStack {
                Image(systemName: "folder.fill")
                if !folder.files.isEmpty {
                  Text(String(folder.files.count))
                    .font(.system(size: 9, weight: .black))
                    .monospaced()
                    .foregroundStyle(theme.surface.backgroundColor)
                    .fixedSize()
                    .frame(width: 30, height: 30)
                    .offset(y: 3)
                }
              }
            }
          }.font(.system(size: 20, weight: .regular))
            .frame(width: 30)
            .padding(.trailing, 2)
          Text(file.name)
            .font(.system(size: 16, weight: .regular))
            .lineLimit(1)
            .truncationMode(.middle)
          
          Spacer(minLength: 0)
          Text(file.size.string())
            .font(.system(size: 16, weight: .regular))
            .lineLimit(1)
          if case .folder = file {
            Image(systemName: "chevron.right")
              .font(.system(size: 16, weight: .regular))
              .foregroundStyle(theme.surface.foreground.tertiary.style)
          }
        }
      }.frame(height: 56)
        .readFrame(to: $globalFrame)
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.4, maximumDistance: 4)
          .onEnded { success in
            guard success else { return }
            ButtonHaptics.buttonFeedback()
            windowModel.present {
              HelloMenu(
                position: globalFrame.center,
                anchor: .bottom,
                items: [
                  HelloMenuItem(name: "Delete", icon: "trash") {
                    windowModel.show(alert: HelloAlertConfig(
                      title: "Delete File?",
                      message: "This can not be undone.",
                      firstButton: .cancel,
                      secondButton: .init(
                        name: "Delete",
                        action: { fileModel.delete(file: file.url) },
                        isDestructive: true)))
                  }
                ])
            }
          })
    }
  }
}
#endif
