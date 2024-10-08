#if os(iOS)
import SwiftUI
import StoreKit

import HelloCore
import HelloApp

struct MoreAppsSettingsPageContent: View {
  
  @Environment(\.theme) private var theme
  @Environment(\.pageID) private var pageID
  @Environment(PagerModel.self) private var pagerModel
  
  @NonObservedState private var targetPresentedApp: KnownApp?
  @State private var presentedApp: KnownApp?
  
  var body: some View {
    VStack(spacing: 24) {
      HelloSection {
        LazyVStack(spacing: 0) {
          ForEach(KnownApp.all) { app in
            HelloButton(clickStyle: .highlight, action: {
              guard presentedApp != app else { return }
              targetPresentedApp = app
              if presentedApp != nil {
                presentedApp = nil
                try? await Task.sleep(seconds: 0.8)
              }
              guard targetPresentedApp == app else { return }
              presentedApp = app
            }) {
              HelloSectionItem(leadingDividerPadding: 82) {
                HStack(spacing: 10) {
                  KnownAppIconView(app: app, prefferedPlatform: .iOS)
                    .frame(width: 60, height: 60)
                  
                  VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                      .font(.system(size: 16, weight: .medium))
                      .foregroundStyle(theme.foreground.primary.style)
                    Text(app.description)
                      .font(.system(size: 13, weight: .medium))
                      .foregroundStyle(theme.foreground.tertiary.style)
                  }
                }
              }
            }
          }
        }
      }
    }.appStoreOverlay(isPresented: .init(
      get: { presentedApp != nil },
      set: {
        if !$0 {
          presentedApp = nil
        }
      })) {
        var config = SKOverlay.AppConfiguration(appIdentifier: targetPresentedApp?.appleID ?? "", position: .bottom)
        config.userDismissible = false
        return config
      }
      .onChange(of: pagerModel.activePageID) {
        if pagerModel.activePageID != pageID && presentedApp != nil {
          presentedApp = nil
        }
      }
  }
}
#endif
