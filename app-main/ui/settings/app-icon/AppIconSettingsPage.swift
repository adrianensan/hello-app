#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct AppIconSettingsPage<AppIcon: BaseAppIcon>: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeArea
  @Environment(PagerModel.self) private var pagerModel
  @Environment(AppIconModel<AppIcon>.self) private var appIconModel
  
  private let subscriptionModel: HelloSubscriptionModel = .main
  
  var body: some View {
    NavigationPage(title: "App Icon") {
      VStack(alignment: .leading, spacing: 16) {
        ForEach(appIconModel.collections) { collection in
          HelloSection(title: collection.name?.uppercased()) {
            LazyVGrid(columns: [.init(.adaptive(minimum: 60, maximum: 160), spacing: 24)], spacing: 16) {
              ForEach(collection.icons) { icon in
                HelloButton(haptics: .action, action: {
                  guard icon.availability != .paid || subscriptionModel.allowPremiumFeatures else {
                    pagerModel.push { HelloSubscriptionPage() }
                    return
                  }
                  appIconModel.set(icon: icon)
                }) {
                  AppIconOptionView(icon: icon, isSelected: icon == appIconModel.currentIcon, showLabel: collection.layout.showLabel)
                }.buttonStyle(.scale(haptics: .onAction))
                  .overlay {
                    if icon.availability == .paid && !subscriptionModel.allowPremiumFeatures {
                      Image(systemName: "lock.fill")
                        .font(.system(size: 12, weight: .medium))
                        .monospacedDigit()
                        .foregroundStyle(theme.theme.baseLayer.accent.mainColor.readableOverlayColor.swiftuiColor)
                        .fixedSize()
                        .frame(24)
                        .background(Circle().fill(theme.floating.accent.style))
                        .overlay(Circle().strokeBorder(theme.floating.backgroundColor, lineWidth: 1))
                        .frame(width: 17, height: 17)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                  }
              }
            }.padding(16)
              .background(theme.surface.backgroundView(for: .rect, isBaseLayer: true))
          }
        }
      }
    }
  }
}
#endif
