#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct DeveloperSettingsPageContent<AdditionalContent: View>: View {
  
  @ViewBuilder var additionalContent: @MainActor () -> AdditionalContent
  
  @Persistent(.isDeveloper) private var isDeveloper
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      HelloSection(title: "UI") {
        UIMetricsRow()
        ShowDebugContentSettingsItem()
        ShowTouchesSettingsItem()
        ShowDebugBordersSettingsItem()
        DisableViewMaskingSettingsItem()
      }
      
      HelloSection(title: "DIAGNOSTICS") {
        PersistenceExplorerSettingsRow()
        LogsSettingsItem()
      }
      
      HelloSection {
        DemoModeSettingsItem()
        if isDeveloper && helloApplication.appConfig.hasPremiumFeatures {
          ActiveSubscriptionSettingsRow()
        }
      }
      
      additionalContent()
      
      HelloSection(title: "RESET") {
        ClearCacheSettingsItem()
        DeleteEverythingSettingsItem()
      }
    }
  }
}
#endif
