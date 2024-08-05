#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

@MainActor
struct DeveloperSettingsPage<AdditionalContent: View>: View {
  
  @ViewBuilder var additionalContent: @MainActor () -> AdditionalContent
  
  public var body: some View {
    NavigationPage(title: "Developer") {
      VStack(alignment: .leading, spacing: 32) {
        HelloSection(title: "UI") {
          ShowTouchesSettingsItem()
          ShowDebugBordersSettingsItem()
        }
        
        HelloSection {
          LogsSettingsItem()
        }
        
        additionalContent()
      }
    }
  }
}
#endif
