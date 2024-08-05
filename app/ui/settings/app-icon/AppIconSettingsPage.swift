import SwiftUI

import HelloCore
import HelloApp

@MainActor
struct AppIconSettingsPage<AppIcon: IOSAppIcon>: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeArea
  @Environment(AppIconModel<AppIcon>.self) private var appIconModel
  
  var body: some View {
    NavigationPage(title: "App Icon") {
      VStack(alignment: .leading, spacing: 16) {
        ForEach(AppIcon.collections) { collection in
          HelloSection(title: collection.name) {
            LazyVGrid(columns: [.init(.adaptive(minimum: 60, maximum: 160), spacing: 24)], spacing: 16) {
              ForEach(collection.icons) { icon in
                HelloButton(haptics: .action, action: { appIconModel.set(icon: icon) }) {
                  AppIconOptionView(icon: icon, isSelected: icon == appIconModel.currentIcon, showLabel: collection.layout.showLabel)
                }.buttonStyle(.scale(haptics: .onAction))
              }
            }.padding(16)
          }
        }
      }
    }
  }
}
