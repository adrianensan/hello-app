#if os(iOS)
import SwiftUI

import HelloCore

struct MoreAppsSettingsPage: View {
  
  var body: some View {
    NavigationPage(title: "More Apps") {
      MoreAppsSettingsPageContent()
    }
  }
}
#endif
