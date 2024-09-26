#if os(iOS)
import SwiftUI

import HelloCore
import HelloApp

struct MoreAppsSettingsPage: View {
  
  var body: some View {
    NavigationPage(title: "More Apps") {
      MoreAppsSettingsPageContent()
    }
  }
}
#endif
