#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct DeveloperSettingsPage<AdditionalContent: View>: View {
  
  @ViewBuilder var additionalContent: @MainActor () -> AdditionalContent
  
  @Persistent(.isDeveloper) private var isDeveloper
  
  public var body: some View {
    NavigationPage(title: "Developer") {
      VStack(alignment: .leading, spacing: 24) {
        HelloSection(title: "UI") {
          ShowDebugContentSettingsItem()
          ShowTouchesSettingsItem()
          ShowDebugBordersSettingsItem()
        }
        
        HelloSection(title: "DIAGNOSTICS") {
          PersistenceExplorerSettingsRow()
          LogsSettingsItem()
        }
        
        HelloSection {
          DemoModeSettingsItem()
          if isDeveloper {
            ActiveSubscriptionSettingsRow()
          }
        }
        
        HelloSection(title: "RESET") {
          ClearCacheSettingsItem()
          DeleteEverythingSettingsItem()
        }
        
        additionalContent()
      }
    }
  }
}
#endif
