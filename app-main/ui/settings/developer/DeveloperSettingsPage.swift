#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct DeveloperSettingsPage<AdditionalContent: View>: View {
  
  @ViewBuilder var additionalContent: @MainActor () -> AdditionalContent
  
  public var body: some View {
    NavigationPage(title: "Developer") {
      DeveloperSettingsPageContent(additionalContent: additionalContent)
    }
  }
}
#endif
