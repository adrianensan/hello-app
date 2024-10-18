#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct AppIconSettingsPageOption: View {
  
  @Environment(\.theme) private var theme
  @Environment(PagerModel.self) private var pagerModel
  @Environment(NewAppIconModel.self) private var appIconModel
  
  var icon: AppIconOption
  
  var isSelected: Bool { icon.id == appIconModel.currentIcon.id }
  
  var body: some View {
    HelloButton(haptics: .action, action: {
      guard icon.isAvailable else {
        pagerModel.push { HelloSubscriptionPage() }
        return
      }
      appIconModel.set(icon: icon.icon)
    }) {
      
      VStack(spacing: 4) {
        NewAppIconView(icon: icon.icon)
          .frame(width: 60, height: 60)
          .padding(4)
          .background {
            AppIconShape()
              .stroke(theme.surface.accent.style, lineWidth: 3)
              .opacity(isSelected ? 1 : 0)
          }
//        if showLabel {
          Text(icon.name)
            .lineLimit(1)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(isSelected ? .white : theme.surface.foreground.primary.color)
            .fixedSize()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
              Capsule(style: .continuous)
                .fill(theme.surface.accent.style)
                .opacity(isSelected ? 1 : 0)
            }
//        }
      }.frame(width: 76)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }.buttonStyle(.scale(haptics: .onAction))
      .overlay {
        if !icon.isAvailable {
          Image(systemName: "lock.fill")
            .font(.system(size: 12, weight: .medium))
            .monospacedDigit()
            .foregroundStyle(theme.accent.readableOverlayColor)
            .fixedSize()
            .frame(24)
            .background(Circle().fill(theme.floating.accent.style))
            .overlay(Circle().strokeBorder(theme.floating.backgroundColor, lineWidth: 1))
            .frame(width: 17, height: 17)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
      }
  }
}

struct NewAppIconSettingsPage: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.safeArea) private var safeArea
  @Environment(PagerModel.self) private var pagerModel
  @Environment(NewAppIconModel.self) private var appIconModel
  
  var body: some View {
    NavigationPage(title: "App Icon") {
      VStack(alignment: .leading, spacing: 16) {
        HelloSection {
          LazyVGrid(columns: [.init(.adaptive(minimum: 60, maximum: 120), spacing: 16)], spacing: 16) {
            ForEach(appIconModel.mainIcons) { icon in
              AppIconSettingsPageOption(icon: icon)
            }
          }.padding(16)
            .background(theme.surface.backgroundView(for: .rect, isBaseLayer: true))
        }
        
        HelloSection {
          HelloSectionItem {
            LazyVGrid(columns: .init(repeating: .init(.flexible(minimum: 44, maximum: 88), spacing: 4), count: 6), alignment: .leading, spacing: 8) {
              ForEach(appIconModel.tintOptions) { tint in
                HelloButton(action: { appIconModel.updateTint(to: tint) }) {
                  tint.background.view
                    .clipShape(AppIconShape())
                    .frame(appIconModel.selectedTint == tint ? 36 : 32)
                    .background(AppIconShape().stroke(tint.background.color.swiftuiColor, lineWidth: 2)
                      .frame(appIconModel.selectedTint == tint ? 44 : 30))
                    .overlay(tint.foreground.view
                      .clipShape(Circle())
                      .frame(8))
                    .animation(.fastSpring, value: appIconModel.selectedTint == tint)
                    .frame(44)
                }
              }
            }
          }
          LazyVGrid(columns: [.init(.adaptive(minimum: 60, maximum: 120), spacing: 16)], spacing: 16) {
            ForEach(appIconModel.tintedIcons) { icon in
              AppIconSettingsPageOption(icon: icon)
            }
          }.padding(.top, 8)
            .padding([.horizontal, .bottom], 16)
            .background(theme.surface.backgroundView(for: .rect, isBaseLayer: true))
        }
        
        ForEach(appIconModel.sections) { collection in
          HelloSection(title: collection.name?.uppercased()) {
            LazyVGrid(columns: [.init(.adaptive(minimum: 60, maximum: 120), spacing: 16)], spacing: 16) {
              ForEach(collection.icons) { icon in
                AppIconSettingsPageOption(icon: icon)
              }
            }.padding(16)
              .background(theme.surface.backgroundView(for: .rect, isBaseLayer: true))
          }
        }
      }
    }.onAppear { appIconModel.refresh() }
  }
}
#endif
