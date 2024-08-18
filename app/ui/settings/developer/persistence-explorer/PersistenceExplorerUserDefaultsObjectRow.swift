#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct PersistenceExplorerUserDefaultsObjectRow: View {
  
  @Environment(\.theme) private var theme
  @Environment(HelloWindowModel.self) private var windowModel
  @Environment(PagerModel.self) private var pagerModel
  @Environment(PersistenceExplorerFileModel.self) private var fileModel
  
  @NonObservedState private var globalFrame: CGRect = .zero
  
  var entry: UserDefaultsEntry
  
  public var body: some View {
    HelloButton(clickStyle: .highlight, action: {
    }) {
      HelloSectionItem {
        HStack(spacing: 4) {
          Image(systemName: entry.object.iconName)
            .font(.system(size: 20, weight: .regular, design: .rounded))
            .frame(width: 30)
            .padding(.trailing, 2)
          Text(entry.key)
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .lineLimit(1)
            .truncationMode(.middle)
          
          Spacer(minLength: 0)
          Text("\(entry.object.previewString)")
            .font(.system(size: 16, weight: .regular, design: .rounded))
            .lineLimit(1)
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
                      title: "Delete Entry?",
                      message: "This can not be undone.",
                      firstButton: .cancel,
                      secondButton: .init(
                        name: "Delete",
                        action: { fileModel.delete(userDefaultsObject: entry) },
                        isDestructive: true)))
                  }
                ])
            }
          })
    }
  }
}
#endif
