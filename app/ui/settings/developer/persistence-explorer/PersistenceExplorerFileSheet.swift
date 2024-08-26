#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct PersistenceExplorerFileSheet: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.helloDismiss) private var helloDismiss
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(PersistenceExplorerFileModel.self) private var fileModel
  
  var file: PersistenceFileSnapshot
  
  public var body: some View {
    NavigationPagerView {
      NavigationPage(navBarContent: {
        HStack(spacing: 4) {
          ShareLink(item: file.url) {
            Image(systemName: "square.and.arrow.up")
              .font(.system(size: 20, weight: .regular))
              .foregroundStyle(theme.foreground.primary.style)
              .frame(width: 44, height: 44)
              .clickable()
          }
          HelloButton(action: {
            windowModel.show(alert: HelloAlertConfig(
              title: "Delete File?",
              message: "This can not be undone.",
              firstButton: .cancel,
              secondButton: .init(
                name: "Delete",
                action: {
                  fileModel.delete(file: file.url)
                  helloDismiss()
                },
                isDestructive: true)))
          }) {
            Image(systemName: "trash")
              .font(.system(size: 20, weight: .regular))
              .foregroundStyle(theme.foreground.primary.style)
              .frame(width: 44, height: 44)
              .clickable()
          }
        }.frame(maxWidth: .infinity, alignment: .leading)
      }) {
        VStack(spacing: 16) {
          HelloSection {
            HelloSectionItem {
              HStack(alignment: .top, spacing: 4) {
                Image(systemName: ContentType.inferFrom(fileExtension: file.url.pathExtension).iconName)
                  .font(.system(size: 20, weight: .regular))
                  .frame(width: 32, height: 32)
                  .frame(height: 24)
                Text(file.name)
                  .font(.system(size: 16, weight: .regular))
                  .foregroundStyle(theme.surface.foreground.primary.style)
                  .fixedSize(horizontal: false, vertical: true)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding(.top, 2)
              }
            }
            HelloSectionItem {
              VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                  Image(systemName: "link")
                    .font(.system(size: 20, weight: .regular))
                    .frame(width: 32, height: 32)
                    .frame(height: 1)
                  Text("Full URL")
                    .font(.system(size: 16, weight: .regular))
                    .fixedSize()
                  Spacer(minLength: 0)
                }
                Text(file.url.absoluteString)
                  .font(.system(size: 14, weight: .regular))
                  .foregroundStyle(theme.surface.foreground.tertiary.style)
                  .fixedSize(horizontal: false, vertical: true)
                  .padding(.leading, 36)
              }
            }
            HelloSectionItem {
              HStack(spacing: 4) {
                Image(systemName: "internaldrive")
                  .font(.system(size: 20, weight: .regular))
                  .frame(width: 32, height: 32)
                  .frame(height: 1)
                Text("Size")
                  .font(.system(size: 16, weight: .regular))
                  .fixedSize()
                Spacer(minLength: 16)
                Text(file.size.string())
                  .font(.system(size: 16, weight: .regular))
                  .foregroundStyle(theme.surface.foreground.primary.style)
                  .fixedSize(horizontal: false, vertical: true)
              }
            }
            if let dateModified = file.dateModified {
              HelloSectionItem {
                HStack(spacing: 4) {
                  Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 20, weight: .regular))
                    .frame(width: 32, height: 32)
                    .frame(height: 1)
                  Text("Date Modified")
                    .font(.system(size: 16, weight: .regular))
                    .fixedSize()
                  Spacer(minLength: 16)
                  Text(dateModified.absoluteDateAndTimeString)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(theme.surface.foreground.primary.style)
                }
              }
            }
            if let dateCreated = file.dateCreated {
              HelloSectionItem {
                HStack(spacing: 4) {
                  Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .regular))
                    .frame(width: 32, height: 32)
                    .frame(height: 1)
                  Text("Date Created")
                    .font(.system(size: 16, weight: .regular))
                    .fixedSize()
                  Spacer(minLength: 16)
                  Text(dateCreated.absoluteDateAndTimeString)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(theme.surface.foreground.primary.style)
                }
              }
            }
          }
        }
      }
    }.frame(height: 520)
  }
}
#endif
